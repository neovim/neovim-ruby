require "socket"

module Neovim
  class Stream
    class Timeout < RuntimeError; end

    def initialize(address, port)
      raise("TCP not supported yet") if port
      @connection = UNIXSocket.new(address)
    end

    def read(timeout=1)
      IO.select([@connection], nil, nil, timeout) ||
        raise(Timeout, "Timeout waiting for socket to be readable")

      data = ""
      loop do
        begin
          data << @connection.read_nonblock(4096)
        rescue IO::WaitReadable
          break(data)
        end
      end
    end

    def write(data, timeout=1)
      IO.select(nil, [@connection], nil, timeout) ||
        raise(Timeout, "Timeout waiting for socket to be writable")

      @connection.write(data)
      self
    end
  end
end
