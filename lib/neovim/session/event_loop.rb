require "neovim/logging"
require "socket"

module Neovim
  class Session
    # The lowest level interface to reading from and writing to +nvim+.
    #
    # @api private
    class EventLoop
      include Logging

      # Connect to a TCP socket.
      def self.tcp(host, port)
        socket = Socket.tcp(host, port)
        new(socket)
      end

      # Connect to a UNIX domain socket.
      def self.unix(path)
        socket = Socket.unix(path)
        new(socket)
      end

      # Spawn and connect to a child +nvim+ process.
      def self.child(_argv)
        argv = _argv.include?("--embed") ? _argv : _argv + ["--embed"]

        io = IO.popen(argv, "rb+").tap do |_io|
          Process.detach(_io.pid)
        end

        new(io)
      end

      # Connect to the current process's standard streams. This is used to
      # promote the current process to a Ruby plugin host.
      def self.stdio
        new(STDIN, STDOUT)
      end

      def initialize(rd, wr=rd)
        @rd, @wr = rd, wr
        @running = false
      end

      # Write data to the underlying +IO+. This will block until all the
      # data has been written.
      def write(data)
        start = 0
        size = data.size
        debug("writing #{data.inspect}")

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

      # Run the event loop, reading from the underlying +IO+ and yielding
      # received messages to the block.
      def run
        @running = true

        loop do
          break unless @running
          message = @rd.readpartial(1024 * 16)
          debug("received #{message.inspect}")
          yield message if block_given?
        end
      rescue EOFError
        info("got EOFError")
      rescue => e
        fatal("got unexpected error #{e.inspect}")
        debug(e.backtrace.join("\n"))
      end

      # Stop the event loop.
      def stop
        @running = false
      end

      # Stop the event loop and close underlying +IO+s.
      def shutdown
        stop

        [@rd, @wr].each do |io|
          begin
            io.close
          rescue IOError
          end
        end
      end
    end
  end
end
