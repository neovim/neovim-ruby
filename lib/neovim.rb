#require "neovim/client"
#require "neovim/current"
#require "neovim/object"
#require "neovim/rpc"
#require "neovim/version"

require "neovim/client"
require "neovim/event_loop"
require "neovim/msgpack_stream"
require "neovim/async_session"
require "neovim/session"

module Neovim
  def self.attach(target)
    host, port = target.split(":")

    if port
      event_loop = EventLoop.tcp(host, port)
    else
      event_loop = EventLoop.unix(host)
    end

    msgpack_stream = MsgpackStream.new(event_loop)
    async_session = AsyncSession.new(msgpack_stream)
    session = Session.new(async_session)

    Client.from_session(session)
  end
end
