require "neovim/client"
require "neovim/connection"
require "neovim/current"
require "neovim/object"
require "neovim/rpc"
require "neovim/version"

module Neovim
  def self.connect(target)
    connection = Connection.parse(target)
    rpc = RPC.new(connection.to_io)

    Client.new(rpc)
  end
end
