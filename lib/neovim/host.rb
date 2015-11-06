module Neovim
  class Host
    def self.load_from_files(rplugin_paths)
      plugins_before = Neovim.__configured_plugins
      captured_plugins = []

      begin
        Neovim.__configured_plugins = captured_plugins

        rplugin_paths.each do |rplugin_path|
          ::Kernel.load(rplugin_path, true)
        end

        new(captured_plugins)
      ensure
        Neovim.__configured_plugins = plugins_before
      end
    end

    attr_reader :plugins

    def initialize(plugins)
      @plugins = plugins
    end

    def run
      event_loop = EventLoop.stdio
      msgpack_stream = MsgpackStream.new(event_loop)
      async_session = AsyncSession.new(msgpack_stream)
      session = Session.new(async_session)
      client = Client.new(session)

      notification_callback = Proc.new do |notification|
        @plugins.each do |plugin|
          plugin.specs.each do |spec|
            if !spec[:sync] && spec[:name] == notification.method_name
              spec[:proc].call(client, *notification.arguments)
            end
          end
        end
      end

      request_callback = Proc.new do |request|
        @plugins.each do |plugin|
          plugin.specs.each do |spec|
            if spec[:sync] && spec[:name] == request.method_name
              result = spec[:proc].call(client, *request.arguments)
              request.respond(result)
            end
          end
        end
      end

      async_session.run(request_callback, notification_callback)
    end
  end
end
