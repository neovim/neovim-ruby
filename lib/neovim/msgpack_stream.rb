require "msgpack"

module Neovim
  class MsgpackStream
    def initialize(server)
      @server = server
      @unpacker = MessagePack::Unpacker.new
    end

    def send(msg)
      @server.send(MessagePack.pack(msg))
    end

    def run(&message_cb)
      @server.run do |data|
        @unpacker.feed_each(data) do |msg|
          message_cb.call(msg)
        end
      end
    end

    def stop
      @server.stop
    end
  end
end
