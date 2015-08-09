require "neovim/client"
require "neovim/current"
require "neovim/message_pack_stream"
require "neovim/object"
require "neovim/version"

module Neovim
  InvalidAddress = Class.new(ArgumentError)

  def self.connect(target)
    case target
    when IO
      Client.new(target)
    when String, Pathname
      address, port = target.to_s.split(":")

      if port
        Client.new(TCPSocket.new(address, port))
      else
        Client.new(UNIXSocket.new(address))
      end
    else
      raise InvalidAddress, "Can't connect to object '#{target.inspect}'"
    end
  rescue => e
    raise InvalidAddress, e.message
  end
end
