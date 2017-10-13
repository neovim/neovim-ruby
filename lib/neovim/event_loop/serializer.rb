require "neovim/logging"
require "msgpack"

module Neovim
  class EventLoop
    # Handles serializing RPC messages to and from MessagePack
    #
    # @api private
    class Serializer
      include Logging

      def initialize(unpacker = MessagePack::Unpacker.new)
        @unpacker = unpacker
      end

      # Serialize an RPC message
      def write(obj)
        log_debug(__method__, :object => obj)
        yield MessagePack.pack(obj)
      end

      def read(bytes)
        @unpacker.feed_each(bytes) do |obj|
          log_debug(__method__, :object => obj)
          yield obj
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
