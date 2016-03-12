require "neovim/logging"
require "msgpack"

module Neovim
  class MsgpackStream
    include Logging

    def initialize(event_loop)
      @event_loop = event_loop
      @unpacker = MessagePack::Unpacker.new
    end

    def send(msg)
      debug("sending #{msg.inspect}")
      @event_loop.send(MessagePack.pack(msg))
      self
    end

    def run(message_cb, session=nil)
      data_cb = Proc.new do |data|
        @unpacker.feed_each(data) do |msg|
          debug("received #{msg.inspect}")
          message_cb.call(msg)
        end
      end

      register_types(session)
      @event_loop.run(data_cb)
    rescue => e
      fatal("got unexpected error #{e}")
      debug(e.backtrace.join("\n"))
    end

    def stop
      @event_loop.stop
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
