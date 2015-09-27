require "eventmachine"

module Neovim
  class EventLoop
    def self.tcp(host, port)
      new(host, port)
    end

    def self.unix(path)
      new(path, nil)
    end

    def initialize(host, port)
      @host, @port = host, port
      @message_queue = EM::Queue.new
    end

    def send(data)
      if EM.reactor_running? && @connection.respond_to?(:send_data)
        @connection.send_data(data)
      else
        @message_queue.push(data)
      end

      self
    end

    def run(&message_callback)
      message_callback ||= Proc.new {}

      EM.run do
        trap(:INT)  { stop }
        trap(:TERM) { stop }


        EM.connect(@host, @port, Connection) do |connection|
          @connection = connection
          @connection.message_callback = message_callback
          @message_queue.pop { |data| @connection.send_data(data) }
        end
      end
    ensure
      @message_callback = nil
    end

    def stop
      EM.stop_event_loop
      self
    end

    class Connection < EM::Connection
      attr_accessor :message_callback

      def receive_data(data)
        @message_callback.call(data)
      end
    end
  end
end
