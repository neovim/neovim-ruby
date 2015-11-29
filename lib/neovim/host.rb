require "neovim/manifest"

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

        manifest = Manifest.load_from_plugins(captured_plugins)
        new(manifest)
      ensure
        Neovim.__configured_plugins = plugins_before
      end
    end

    attr_reader :manifest

    def initialize(manifest)
      @manifest = manifest
      @event_loop = EventLoop.stdio
      @msgpack_stream = MsgpackStream.new(@event_loop)
      @async_session = AsyncSession.new(@msgpack_stream)
    end

    def run
      request_callback = Proc.new do |req|
        @manifest.handle_request(req, client)
      end

      notification_callback = Proc.new do |ntf|
        @manifest.handle_notification(ntf, client)
      end

      @async_session.run(request_callback, notification_callback)
    end

    private

    def client
      @client ||= Client.new(Session.new(@async_session))
    end
  end
end
