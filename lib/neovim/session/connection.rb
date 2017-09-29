require "neovim/logging"
require "socket"

module Neovim
  class Session
    # The lowest level interface to reading from and writing to +nvim+.
    #
    # @api private
    class Connection
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

        io = ::IO.popen(argv, "rb+").tap do |_io|
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
        written = 0
        total = data.bytesize
        debug("writing #{data.inspect}")

        begin
          while written < total
            written += @wr.write_nonblock(data[written..-1])
          end
        rescue ::IO::WaitWritable
          ::IO.select(nil, [@wr], nil, 1)
          retry
        ensure
          @wr.flush
        end
      end

      def read
        debug("reading")
        @rd.readpartial(1024 * 16).tap do |bytes|
          debug("received #{bytes.inspect}")
          yield bytes
        end
      end

      # Close underlying +IO+s.
      def close
        [@rd, @wr].each do |io|
          begin
            io.close
          rescue ::IOError
          end
        end
      end
    end
  end
end
