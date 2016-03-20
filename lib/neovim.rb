require "neovim/async_session"
require "neovim/client"
require "neovim/event_loop"
require "neovim/host"
require "neovim/msgpack_stream"
require "neovim/session"
require "neovim/plugin"

module Neovim
  class << self
    attr_accessor :__configured_plugin_manifest, :__configured_plugin_path
  end

  def self.attach_tcp(host, port)
    Client.new(Session.tcp(host, port).discover_api)
  end

  def self.attach_unix(socket_path)
    Client.new(Session.unix(socket_path).discover_api)
  end

  def self.attach_child(argv=[])
    Client.new(Session.child(argv).discover_api)
  end

  def self.start_host(rplugin_paths)
    Host.load_from_files(rplugin_paths).run
  end

  def self.plugin(&block)
    Plugin.from_config_block(__configured_plugin_path, &block).tap do |plugin|
      if __configured_plugin_manifest.respond_to?(:register)
        __configured_plugin_manifest.register(plugin)
      end
    end
  end

  def self.logger=(logger)
    Logging.logger = logger
  end

  def self.logger
    Logging.logger
  end
end
