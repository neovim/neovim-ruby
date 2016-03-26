require "neovim/logging"

module Neovim
  class Manifest
    include Logging

    attr_reader :handlers, :specs

    def initialize
      @handlers = {"poll" => poll_handler, "specs" => specs_handler}
      @specs = {}
    end

    # Register a +Plugin+ to receive +Host+ messages.
    #
    # @param plugin [Plugin]
    def register(plugin)
      plugin.handlers.each do |handler|
        wrapped_handler = handler.sync? ? wrap_sync(handler) : wrap_async(handler)
        @handlers[handler.qualified_name] = wrapped_handler
      end

      @specs[plugin.source] = plugin.specs
    end

    # Handle messages received from the host. Sends a +Neovim::Client+ along
    # with the message to be used in plugin callbacks.
    #
    # @param message [Neovim::Request, Neovim::Notification]
    # @param client [Neovim::Client]
    def handle(message, client)
      default_handler = message.sync? ? default_sync_handler : default_async_handler
      @handlers.fetch(message.method_name, default_handler).call(client, message)
    rescue => e
      fatal("got unexpected error #{e}")
      debug(e.backtrace.join("\n"))
    end

    private

    def poll_handler
      @poll_handler ||= Proc.new do |_, req|
        debug("received 'poll' request #{req.inspect}")
        req.respond("ok")
      end
    end

    def specs_handler
      @specs_handler ||= Proc.new do |_, req|
        debug("received 'specs' request #{req.inspect}")
        source = req.arguments.fetch(0)

        if @specs.key?(source)
          req.respond(@specs.fetch(source))
        else
          req.error("Unknown plugin #{source}")
        end
      end
    end

    def default_sync_handler
      @default_sync_handler ||= Proc.new { |_, req| req.error("Unknown request #{req.method_name}") }
    end

    def default_async_handler
      @default_async_handler ||= Proc.new {}
    end

    def wrap_sync(handler)
      Proc.new do |client, request|
        debug("received #{request.inspect}")
        request.respond(handler.call(client, *request.arguments[0]))
      end
    end

    def wrap_async(handler)
      Proc.new do |client, notification|
        debug("received #{notification.inspect}")
        handler.call(client, *notification.arguments[0])
      end
    end
  end
end
