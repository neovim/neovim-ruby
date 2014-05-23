require "neovim/version"
require "neovim/client"
require "neovim/stream"
require "neovim/rpc"
require "neovim/variable"

module Neovim
  Remote = Struct.new(:vim, :handle)

  def self.discover_api(stream)
    response = RPC.new([0, 0, 0, []], stream).response
    MessagePack.unpack(response[3])
  end
end
