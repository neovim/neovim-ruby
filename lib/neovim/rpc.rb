require "msgpack"

module Neovim
  class RPC
    class Error < RuntimeError; end

    def initialize(stream, client)
      @request  = -1
      @client   = client
      @packer   = MessagePack::Packer.new(stream)
      @unpacker = MessagePack::Unpacker.new(stream)
    end

    def register_types(types)
      types.each do |type, info|
        klass = Neovim.const_get(type)
        id = info.fetch("id")

        @packer.register_type(id, klass) do |obj|
          MessagePack.pack(obj.index)
        end

        @unpacker.register_type(id) do |data|
          klass.new(MessagePack.unpack(data), @client)
        end
      end
    end

    def send(function, *args)
      @packer.write_array_header(4).
        write(0).
        write(@request += 1).
        write(function.to_s).
        write(args).
        flush

      self
    end

    def response
      _, _, error_msg, response = @unpacker.read
      raise(Error, error_msg) if error_msg
      response
    end
  end
end
