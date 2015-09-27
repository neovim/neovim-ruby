#require "neovim/client"
#require "neovim/current"
#require "neovim/object"
#require "neovim/rpc"
#require "neovim/version"

require "neovim/server"
require "neovim/msgpack_stream"
require "neovim/async_session"
require "neovim/session"

module Neovim
  #def self.connect(target)
  #  connection = Connection.parse(target)
  #  rpc = RPC.new(connection.to_io)

  #  Client.new(rpc)
  #end
end
