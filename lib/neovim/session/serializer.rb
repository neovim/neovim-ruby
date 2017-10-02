require "neovim/logging"
require "msgpack"

module Neovim
  class Session
    # Handles serializing RPC messages to and from MessagePack
    #
    # @api private
    class Serializer
      include Logging

      def initialize(unpacker = MessagePack::Unpacker.new)
        @unpacker = unpacker
      end

      # Serialize an RPC message
      def write(msg)
        debug("write #{msg.inspect}")
        yield MessagePack.pack(msg)
      end

      def read(bytes)
        @unpacker.feed_each(bytes) do |object|
          debug("read #{object.inspect}")
          yield object
        end
      end

      def register_type(id, &block)
        @unpacker.register_type(id) do |data|
          index = MessagePack.unpack(data)
          block.call(index)
        end
      end
    end
  end
end
