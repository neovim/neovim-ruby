require "eventmachine"
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
      @read_stream, @write_stream = rd, wr
    end

    def send(data)
      EM.schedule do
        @write_conn.send_data(data)
      end
      self
    end

    def run(&message_callback)
      message_callback ||= Proc.new {}

      EM.run do
        @read_conn = EM.watch(@read_stream, Connection)
        @write_conn = EM.watch(@write_stream, Connection) unless @write_stream == @read_stream
        @write_conn ||= @read_conn

        @read_conn.notify_readable = true
        @read_conn.message_callback = message_callback
      end
    end

    def stop
      EM.stop_event_loop
      self
    end

    def shutdown
      stop
      self
    ensure
      @read_conn.close if @read_conn.respond_to?(:close)
      @write_conn.close if @write_conn.respond_to?(:close)
    end

    class Connection < EM::Connection
      attr_writer :message_callback

      def send_data(data)
        @io.write_nonblock(data)
      end

      def notify_readable
        @message_callback.call(@io.readpartial(1024 * 16))
      end
    end
  end
end
