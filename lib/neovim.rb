require "neovim/async_session"
require "neovim/client"
require "neovim/event_loop"
require "neovim/host"
require "neovim/msgpack_stream"
require "neovim/session"
require "neovim/plugin"

module Neovim
  @__configured_plugins = []

  def self.attach_tcp(host, port)
    attach_event_loop(EventLoop.tcp(host, port))
  end

  def self.attach_unix(socket_path)
    attach_event_loop(EventLoop.unix(socket_path))
  end

  def self.attach_child(argv=[])
    attach_event_loop(EventLoop.child(argv))
  end

  def self.start_host(rplugin_paths)
    Host.load_from_files(rplugin_paths).run
  end

  def self.plugin(&block)
    Plugin.from_config_block(&block).tap do |plugin|
      __configured_plugins << plugin
    end
  end

  class << self
    attr_accessor :__configured_plugins

    private

    def attach_event_loop(event_loop)
      msgpack_stream = MsgpackStream.new(event_loop)
      async_session = AsyncSession.new(msgpack_stream)
      session = Session.new(async_session)

      Client.new(session)
    end
  end
end
