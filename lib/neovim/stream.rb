require "socket"

module Neovim
  class Stream
    class Timeout < RuntimeError; end

    def initialize(address, port)
      raise("TCP not supported yet") if port
      @connection = UNIXSocket.new(address)
    end

    def read
      IO.select([@connection], nil, nil, 1) ||
        raise(Timeout, "Timeout waiting for socket to be readable")

      data = ""
      loop do
        begin
          data << @connection.read_nonblock(4096)
        rescue IO::WaitReadable
          break(data)
        rescue EOFError
          break(nil)
        end
      end
    end

    def write(data)
      IO.select(nil, [@connection], nil, 1) ||
        raise(Timeout, "Timeout waiting for socket to be writable")

      @connection.write(data)
    end
  end
end
