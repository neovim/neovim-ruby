require "neovim/async_session"
require "neovim/client"
require "neovim/event_loop"
require "neovim/msgpack_stream"
require "neovim/session"

module Neovim
  class Plugin
    def self.from_config_block(&block)
      new.tap do |instance|
        block.call(instance) if block
      end
    end

    attr_reader :request_handler, :notification_handler

    def initialize
      @request_handler = ::Proc.new {}
      @notification_handler = ::Proc.new {}
    end

    def on_request(&block)
      @request_handler = block || ::Proc.new {}
    end

    def on_notification(&block)
      @notification_handler = block || ::Proc.new {}
    end

    def run
      event_loop = EventLoop.stdio
      msgpack_stream = MsgpackStream.new(event_loop)
      async_session = AsyncSession.new(msgpack_stream)
      session = Session.new(async_session)
      client = Client.new(session)

      request_cb = ::Proc.new do |request|
        @request_handler.call(request, client)
      end

      notification_cb = ::Proc.new do |notification|
        @notification_handler.call(notification, client)
      end

      begin
        async_session.run(request_cb, notification_cb)
      ensure
        async_session.shutdown
      end
    end
  end
end
