require "eventmachine"
require "socket"

module Neovim
  class EventLoop
    def self.tcp(host, port)
      new TCPSocket.new(host, port)
    end

    def self.unix(path)
      new UNIXSocket.new(path)
    end

    def self.child(argv)
      argv = [ENV.fetch("NVIM_EXECUTABLE", "nvim"), "--embed"] | argv.to_ary
      new IO.popen(argv, "rb+")
    end

    def initialize(io)
      @io = io
    end

    def send(data)
      EM.schedule do
        @connection.send_data(data)
      end
      self
    end

    def run(&message_callback)
      message_callback ||= Proc.new {}

      EM.run do
        @connection = EM.watch(@io, Connection)
        @connection.notify_readable = true
        @connection.message_callback = message_callback
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
      @io.close if @io.respond_to?(:close)
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
