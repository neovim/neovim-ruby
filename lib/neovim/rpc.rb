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

    def send(function, *_args)
      args = msgpack_args(_args)

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

      to_neovim_object(response)
    end

    private

    def msgpack_args(args)
      args.map do |obj|
        obj.respond_to?(:msgpack_data) ? obj.msgpack_data : obj
      end
    end

    def to_neovim_object(obj)
      if obj.is_a?(MessagePack::Extended)
        klass = @client.class_for(obj.type)
        data  = obj.data.unpack("c*").fetch(0)

        klass.new(data, @client)
      elsif obj.respond_to?(:to_ary)
        obj.map { |elem| to_neovim_object(elem) }
      else
        obj
      end
    end
  end
end
