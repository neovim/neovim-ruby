module Neovim
  class Manifest
    attr_reader :handlers, :specs

    def initialize
      @handlers = {"poll" => poll_handler, "specs" => specs_handler}
      @specs = {}
    end

    def register(plugin)
      plugin.handlers.each do |handler|
        wrapped_handler = handler.sync? ? wrap_sync(handler) : wrap_async(handler)
        @handlers[handler.qualified_name] = wrapped_handler
      end

      @specs[plugin.source] = plugin.specs
    end

    def handle(msg, client)
      default_handler = msg.sync? ? default_sync_handler : default_async_handler
      @handlers.fetch(msg.method_name, default_handler).call(client, msg)
    end

    private

    def poll_handler
      @poll_handler ||= Proc.new { |_, req| req.respond("ok") }
    end

    def specs_handler
      @specs_handler ||= Proc.new do |_, req|
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
        request.respond(handler.call(client, *request.arguments[0]))
      end
    end

    def wrap_async(handler)
      Proc.new do |client, notification|
        handler.call(client, *notification.arguments[0])
      end
    end
  end
end
