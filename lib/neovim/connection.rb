require "socket"
require "pathname"
require "delegate"

module Neovim
  class Connection < SimpleDelegator
    Error = Class.new(ArgumentError)

    def self.parse(target)
      case target
      when IO
        target
      when String, Pathname
        address, port = target.to_s.split(":")

        if port
          new TCPSocket.new(address, port)
        else
          new UNIXSocket.new(address)
        end
      else
        raise "Can't connect to object '#{target.inspect}'"
      end
    rescue => e
      raise Error, e.message
    end
  end
end
