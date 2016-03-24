require "neovim/logging"
require "socket"

module Neovim
  # The lowest level interface to reading from and writing to +nvim+.
  class EventLoop
    include Logging

    private_class_method :new

    # Connect to a TCP socket
    #
    # @param host [String] The hostname or IP address
    # @param port [Fixnum] The port
    # @return [EventLoop]
    def self.tcp(host, port)
      socket = TCPSocket.new(host, port)
      new(socket)
    end

    # Connect to a UNIX domain socket
    #
    # @param path [String] The socket path
    # @return [EventLoop]
    def self.unix(path)
      socket = UNIXSocket.new(path)
      new(socket)
    end

    # Spawn and connect to a child +nvim+ process
    #
    # @param argv [Array] The arguments to pass to the spawned process
    # @return [EventLoop]
    def self.child(argv)
      argv = [ENV.fetch("NVIM_EXECUTABLE", "nvim"), "--embed"] | argv
      io = IO.popen(argv, "rb+")
      new(io)
    end

    # Connect to the current process's standard streams. This is used to
    # promote the current process to a Ruby plugin host.
    #
    # @return [EventLoop]
    def self.stdio
      new(STDIN, STDOUT)
    end

    def initialize(rd, wr=rd)
      @rd, @wr = rd, wr
      @running = false
    end

    # Write data to the underlying +IO+. This will block until all the
    # data has been written.
    #
    # @param data [String] The data to write (typically message-packed)
    # @return [self]
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
    #
    # @yield [String]
    # @return [void]
    def run
      @running = true

      loop do
        break unless @running
        message = @rd.readpartial(1024 * 16)
        debug("received #{message.inspect}")
        yield message if block_given?
      end
    rescue EOFError
      warn("got EOFError")
    rescue => e
      fatal("got unexpected error #{e}")
      debug(e.backtrace.join("\n"))
    end

    # Stop the event loop
    #
    # @return [void]
    def stop
      @running = false
    end

    # Stop the event loop and close underlying +IO+s
    #
    # @return [void]
    def shutdown
      stop
      [@rd, @wr].each(&:close)
    rescue IOError
    end
  end
end
