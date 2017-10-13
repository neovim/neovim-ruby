require "neovim/logging"
require "socket"

module Neovim
  class EventLoop
    # The lowest level interface to reading from and writing to +nvim+.
    #
    # @api private
    class Connection
      include Logging

      def self.tcp(host, port)
        socket = Socket.tcp(host, port)
        new(socket)
      end

      def self.unix(path)
        socket = Socket.unix(path)
        new(socket)
      end

      def self.child(_argv)
        argv = _argv.include?("--embed") ? _argv : _argv + ["--embed"]

        io = ::IO.popen(argv, "rb+").tap do |_io|
          Process.detach(_io.pid)
        end

        new(io)
      end

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
        log(:debug, __method__, :bytes => data.bytesize)

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
        @rd.readpartial(1024 * 16).tap do |bytes|
          log(:debug, __method__, :bytes => bytes.bytesize)
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
