require "neovim/client"
require "neovim/current"
require "neovim/object"
require "neovim/rpc"
require "neovim/version"

module Neovim
  InvalidAddress = Class.new(ArgumentError)

  def self.connect(address, port=nil)
    if port
      Client.new TCPSocket.new(address, port)
    else
      Client.new UNIXSocket.new(address)
    end
  rescue => e
    raise InvalidAddress, e.message
  end
end
