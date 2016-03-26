require "neovim/logging"
require "msgpack"

module Neovim
  # Handles serializing RPC messages to MessagePack and passing them to
  # the event loop
  class MsgpackStream
    include Logging

    def initialize(event_loop)
      @event_loop = event_loop
      @unpacker = MessagePack::Unpacker.new
    end

    # Serialize an RPC message to and write it to the event loop.
    #
    # @param msg [Array] The RPC message
    # @return [self]
    # @example Write an RPC request
    #   msgpack_stream.write([0, 1, :vim_strwidth, ["foobar"]])
    def write(msg)
      debug("writing #{msg.inspect}")
      @event_loop.write(MessagePack.pack(msg))
      self
    end

    # Run the event loop, yielding deserialized messages to the block.
    #
    # @param session [Session] Used for registering msgpack +ext+ types as
    #   described by the +vim_get_api_info+ call
    # @return [void]
    # @see EventLoop#run
    def run(session=nil)
      register_types(session)

      @event_loop.run do |data|
        @unpacker.feed_each(data) do |msg|
          debug("received #{msg.inspect}")
          yield msg if block_given?
        end
      end
    rescue => e
      fatal("got unexpected error #{e}")
      debug(e.backtrace.join("\n"))
    end

    # Stop the event loop.
    #
    # @return [void]
    # @see EventLoop#stop
    def stop
      @event_loop.stop
    end

    # Shut down the event loop.
    #
    # @return [void]
    # @see EventLoop#shutdown
    def shutdown
      @event_loop.shutdown
    end

    private

    def register_types(session)
      return unless session && session.api

      session.api.types.each do |type, info|
        klass = Neovim.const_get(type)
        id = info.fetch("id")

        @unpacker.register_type(id) do |data|
          klass.new(MessagePack.unpack(data), session)
        end
      end
    end
  end
end
