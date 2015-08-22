require "msgpack"

module Neovim
  class RPC
    class Error < RuntimeError; end

    def initialize(conn)
      @request    = -1
      @packer     = MessagePack::Packer.new(conn.to_io)
      @unpacker   = MessagePack::Unpacker.new(conn.to_io)

      register_types
    end

    def send(method_name, *args)
      request(method_name, *args)
      response
    end

    def defined?(method_name)
      !!find_function(method_name.to_s)
    end

    private

    def request(function, *args)
      @packer.write_array_header(4).
        write(0).
        write(@request += 1).
        write(function.to_s).
        write(args).
        flush
    end

    def response
      _, _, error_msg, response = @unpacker.read
      raise(Error, error_msg) if error_msg
      response
    end

    def register_types
      request(:vim_get_api_info)
      @api_info = response

      @api_info.fetch(1).fetch("types").each do |type, info|
        klass = Neovim.const_get(type)
        id = info.fetch("id")

        @packer.register_type(id, klass) do |obj|
          MessagePack.pack(obj.index)
        end

        @unpacker.register_type(id) do |data|
          klass.new(MessagePack.unpack(data), self)
        end
      end
    end

    def find_function(name)
      @api_info.fetch(1).fetch("functions").find do |func|
        func.fetch("name") == name
      end
    end
  end
end
