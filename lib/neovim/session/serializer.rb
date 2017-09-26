require "neovim/logging"
require "msgpack"

module Neovim
  class Session
    # Handles serializing RPC messages to MessagePack and passing them to
    # the event loop.
    #
    # @api private
    class Serializer
      include Logging

      def initialize(io, unpacker=nil)
        @io = io
        @unpacker = unpacker || MessagePack::Unpacker.new
      end

      # Serialize an RPC message to and write it to the event loop.
      def write(msg)
        debug("writing #{msg.inspect}")
        @io.write(MessagePack.pack(msg))
        self
      end

      # Run the event loop, yielding deserialized messages to the block.
      def run
        @io.run do |data|
          @unpacker.feed_each(data) do |msg|
            debug("received #{msg.inspect}")
            yield msg if block_given?
          end
        end
      rescue => e
        fatal("got unexpected error #{e.inspect}")
        debug(e.backtrace.join("\n"))
      end

      # Stop the event loop.
      def stop
        @io.stop
      end

      # Shut down the event loop.
      def shutdown
        @io.shutdown
      end

      # Register msgpack ext types using the provided API and session
      def register_types(api, session)
        info("registering msgpack ext types")
        api.types.each do |type, info|
          klass = Neovim.const_get(type)
          id = info.fetch("id")

          @unpacker.register_type(id) do |data|
            klass.new(MessagePack.unpack(data), session)
          end
        end
      end
    end
  end
end
