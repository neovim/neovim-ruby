module Neovim
  class Manifest
    def self.load_from_plugins(plugins)
      handlers = plugins.inject(default_handlers(plugins)) do |acc, plugin|
        plugin.handlers.each do |handler|
          if handler.sync?
            acc[:sync][handler.name] = wrap_sync_handler(handler)
          else
            acc[:async][handler.name] = wrap_async_handler(handler)
          end
        end

        acc
      end

      new(handlers)
    end

    def self.default_handlers(plugins)
      sync = Hash.new(default_sync_handler).merge(
        :poll => default_poll_handler,
        :specs => default_specs_handler(plugins)
      )
      async = Hash.new(default_async_handler)
      {:sync => sync, :async => async}
    end
    private_class_method :default_handlers

    def self.default_poll_handler
      Proc.new do |_, request|
        request.respond("ok")
      end
    end
    private_class_method :default_poll_handler

    def self.default_specs_handler(plugins)
      Proc.new do |_, request|
        request.respond(plugins.flat_map(&:specs))
      end
    end
    private_class_method :default_specs_handler

    def self.default_sync_handler
      Proc.new do |_, request|
        request.error("Unknown request #{request.method_name.inspect}")
      end
    end
    private_class_method :default_sync_handler

    def self.default_async_handler
      Proc.new {}
    end
    private_class_method :default_async_handler

    def self.wrap_sync_handler(handler)
      Proc.new do |client, request|
        request.respond(handler.call(client, *request.arguments))
      end
    end
    private_class_method :wrap_sync_handler

    def self.wrap_async_handler(handler)
      Proc.new do |client, notification|
        handler.call(client, *notification.arguments)
      end
    end
    private_class_method :wrap_async_handler

    attr_reader :handlers

    def initialize(handlers)
      @handlers = handlers
    end

    def handle_request(req, client)
      @handlers[:sync][req.method_name].call(client, req)
    end

    def handle_notification(ntf, client)
      @handlers[:async][ntf.method_name].call(client, ntf)
    end
  end
end
