require "neovim/logging"
require "socket"

module Neovim
  class EventLoop
    include Logging

    def self.tcp(host, port)
      socket = TCPSocket.new(host, port)
      new(socket, socket)
    end

    def self.unix(path)
      socket = UNIXSocket.new(path)
      new(socket, socket)
    end

    def self.child(argv)
      argv = [ENV.fetch("NVIM_EXECUTABLE", "nvim"), "--embed"] | argv
      io = IO.popen(argv, "rb+")
      new(io, io)
    end

    def self.stdio
      new(STDIN, STDOUT)
    end

    def initialize(rd, wr)
      @rd, @wr = rd, wr
      @running = false
    end

    def send(data)
      start = 0
      size = data.size
      debug("sending #{data.inspect}")

      begin
        while start < size
          start += @wr.write_nonblock(data[start..-1])
        end
        self
      rescue IO::WaitWritable
        IO.select(nil, [@wr], nil, 1)
        retry
      end
    end

    def run(message_callback)
      @running = true

      loop do
        break unless @running
        message = @rd.readpartial(1024 * 16)
        debug("received #{message.inspect}")
        message_callback.call(message)
      end
    rescue EOFError
      warn("got EOFError")
    rescue => e
      fatal("got unexpected error #{e}")
      debug(e.backtrace.join("\n"))
    end

    def stop
      @running = false
    end
  end
end
