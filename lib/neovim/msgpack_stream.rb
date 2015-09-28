require "msgpack"

module Neovim
  class MsgpackStream
    def initialize(event_loop)
      @event_loop = event_loop
      @packer = MessagePack::Packer.new
      @unpacker = MessagePack::Unpacker.new
    end

    def register_session(session)
      session.metadata.types.each do |type, info|
        klass = Neovim.const_get(type)
        id = info.fetch("id")

        @packer.register_type(id, klass) do |obj|
          MessagePack.pack(obj.index)
        end

        @unpacker.register_type(id) do |data|
          klass.new(MessagePack.unpack(data), session)
        end
      end
    end

    def send(msg)
      @event_loop.send(@packer.pack(msg))
      self
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
      self
    end

    def shutdown
      @event_loop.shutdown
      self
    end
  end
end
