require "neovim/logging"
require "neovim/host/manifest"

module Neovim
  # @api private
  class Host
    include Logging

    attr_reader :manifest, :plugin_path

    # Initialize an empty +Host+.
    #
    # @return [Host]
    def self.bare
      new(Manifest.new, Session.stdio)
    end

    def initialize(manifest, session)
      @manifest = manifest
      @session = session
    end

    # Load plugin definitions from +rplugin_paths+.
    #
    # @param rplugin_paths [Array<String>]
    # @return [void]
    # @see Neovim.start_host
    # @see Neovim.plugin
    def load_files(rplugin_paths)
      rplugin_paths.each do |rplugin_path|
        @plugin_path = rplugin_path
        Kernel.load(rplugin_path, true)
      end
    ensure
      @plugin_path = nil
    end

    # Register a plugin, adding it to the manifest.
    #
    # @param plugin [Plugin]
    def register(plugin)
      @manifest.register(plugin)
    end

    # Run the event loop, passing received messages to the manifest.
    #
    # @return [void]
    def run
      @session.discover_api

      @session.run do |msg|
        debug("received #{msg.inspect}")
        @manifest.handle(msg, client)
      end
    rescue => e
      fatal("got unexpected error #{e.inspect}")
      debug(e.backtrace.join("\n"))
    end

    private

    def client
      @client ||= Client.new(@session)
    end
  end
end
