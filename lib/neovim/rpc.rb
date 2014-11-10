require "msgpack"

module Neovim
  class RPC
    class Error < RuntimeError; end

    def initialize(stream)
      @request  = -1
      @packer   = MessagePack::Packer.new(stream)
      @unpacker = MessagePack::Unpacker.new(stream)
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
      @unpacker.read.tap do |payload|
        if error_msg = payload.fetch(2)
          raise Error.new(error_msg)
        end
      end.fetch(3)
    end
  end
end
