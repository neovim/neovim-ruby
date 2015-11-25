module Neovim
  class Host
    def self.load_from_files(rplugin_paths)
      plugins_before = Neovim.__configured_plugins
      captured_plugins = []

      begin
        Neovim.__configured_plugins = captured_plugins

        rplugin_paths.each do |rplugin_path|
          Kernel.load(rplugin_path, true)
        end

        new(captured_plugins)
      ensure
        Neovim.__configured_plugins = plugins_before
      end
    end

    attr_reader :plugins

    def initialize(plugins)
      @plugins = plugins
      @handlers = compile_handlers(plugins)
      @event_loop = EventLoop.stdio
      @msgpack_stream = MsgpackStream.new(@event_loop)
      @async_session = AsyncSession.new(@msgpack_stream)
    end

    def run
      notification_callback = Proc.new do |ntf|
        @handlers[:notification][ntf.method_name].call(client, ntf)
      end

      request_callback = Proc.new do |req|
        @handlers[:request][req.method_name].call(client, req)
      end

      @async_session.run(request_callback, notification_callback)
    end

    private

    def client
      @client ||= Client.new(session)
    end

    def session
      @session ||= Session.new(@async_session)
    end

    def compile_handlers(plugins)
      default_req_handler = Proc.new do |_, req|
        req.error("Unknown request #{req.method_name.inspect}")
      end

      default_ntf_handler = Proc.new {}

      base = {
        :request => Hash.new(default_req_handler),
        :notification => Hash.new(default_ntf_handler)
      }

      base[:request][:poll] = lambda { |_, req| req.respond("ok") }

      plugins.inject(base) do |handlers, plugin|
        plugin.handlers.each do |handler|
          if handler.sync?
            handlers[:request][handler.name] = lambda do |client, req|
              req.respond(handler.call(client, *req.arguments))
            end
          else
            handlers[:notification][handler.name] = lambda do |client, ntf|
              handler.call(client, *ntf.arguments)
            end
          end
        end

        handlers
      end
    end
  end
end
