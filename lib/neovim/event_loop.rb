require "socket"

module Neovim
  class EventLoop
    def self.tcp(host, port)
      socket = TCPSocket.new(host, port)
      new(socket, socket)
    end

    def self.unix(path)
      socket = UNIXSocket.new(path)
      new(socket, socket)
    end

    def self.child(argv)
      argv = [ENV.fetch("NVIM_EXECUTABLE", "nvim"), "--embed"] | argv.to_ary
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
      _, wrs = IO.select(nil, [@wr])
      wrs.each { |wr| wr.write_nonblock(data) }
      self
    end

    def run(&message_callback)
      @running = true
      message_callback ||= Proc.new {}

      loop do
        break unless @running

        rds, = IO.select([@rd])
        rds.each do |io|
          message_callback.call(io.readpartial(1024 * 16))
        end
      end
    rescue EOFError
      stop
    end

    def stop
      @running = false
      self
    end
  end
end
