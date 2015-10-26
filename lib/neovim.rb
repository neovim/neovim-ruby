require "neovim/async_session"
require "neovim/client"
require "neovim/event_loop"
require "neovim/msgpack_stream"
require "neovim/session"
require "neovim/plugin"

module Neovim
  def self.attach_tcp(host, port)
    attach_event_loop(EventLoop.tcp(host, port))
  end

  def self.attach_unix(socket_path)
    attach_event_loop(EventLoop.unix(socket_path))
  end

  def self.attach_child(argv=[])
    attach_event_loop(EventLoop.child(argv))
  end

  def self.plugin(&block)
    Plugin.from_config_block(&block).tap do |plugin|
      plugins << plugin
    end
  end

  def self.plugins
    @plugins ||= []
  end

  class << self
    private

    def attach_event_loop(event_loop)
      msgpack_stream = MsgpackStream.new(event_loop)
      async_session = AsyncSession.new(msgpack_stream)
      session = Session.new(async_session)

      Client.new(session)
    end
  end
end
