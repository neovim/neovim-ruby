require "neovim/logging"
require "neovim/manifest"

module Neovim
  class Host
    include Logging

    attr_reader :manifest

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

    def initialize(manifest, session=nil)
      @session = session || Session.stdio
      @manifest = manifest
    end

    def run
      @session.run do |msg|
        debug("received #{msg.inspect}")
        @manifest.handle(msg, client)
      end
    rescue => e
      fatal("got unexpected error #{e}")
      debug(e.backtrace.join("\n"))
    end

    private

    def client
      @client ||= Client.new(@session.discover_api)
    end
  end
end
