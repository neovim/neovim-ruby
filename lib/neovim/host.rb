require "neovim/manifest"

module Neovim
  class Host
    def self.load_from_files(rplugin_paths, target_manifest=Manifest.new)
      old_manifest = Neovim.__configured_plugin_manifest
      old_path = Neovim.__configured_plugin_path

      begin
        Neovim.__configured_plugin_manifest = target_manifest

        rplugin_paths.each do |rplugin_path|
          Neovim.__configured_plugin_path = rplugin_path
          Kernel.load(rplugin_path, true)
        end

        new(target_manifest)
      ensure
        Neovim.__configured_plugin_manifest = old_manifest
        Neovim.__configured_plugin_path = old_path
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
      callback = Proc.new do |msg|
        @manifest.handle(msg, client)
      end

      @async_session.run(callback, callback)
    end

    private

    def client
      @client ||= Client.new(Session.new(@async_session))
    end
  end
end
