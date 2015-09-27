require "msgpack"

module Neovim
  class MsgpackStream
    def initialize(event_loop)
      @event_loop = event_loop
      @unpacker = MessagePack::Unpacker.new
    end

    def send(msg)
      @event_loop.send(MessagePack.pack(msg))
    end

    def run(&message_cb)
      @event_loop.run do |data|
        @unpacker.feed_each(data) do |msg|
          message_cb.call(msg)
        end
      end
    end

    def stop
      @event_loop.stop
    end
  end
end
