require "eventmachine"

module Neovim
  module Server
    def self.tcp(host, port)
      TCP.new(host, port)
    end

    def self.unix(path)
      Unix.new(path)
    end

    class Base
      def initialize
        @message_queue = EM::Queue.new
      end

      def run(&message_callback)
        @message_callback = message_callback || Proc.new {}

        EM.run do
          trap(:INT)  { stop }
          trap(:TERM) { stop }

          connect
        end
      ensure
        @message_callback = nil
      end

      def send(data)
        if @connection.respond_to?(:send_data)
          @connection.send_data(data)
        else
          @message_queue.push(data)
        end
      end

      def stop
        EM.stop
      end

      private

      def initialize_connection(connection)
        @connection = connection
        @connection.message_callback = @message_callback
        @connection.flush_message_queue(@message_queue)
      end
    end

    class TCP < Base
      def initialize(host, port)
        super()
        @host, @port = host, port
      end

      def connect
        EM.connect(@host, @port, Connection, &method(:initialize_connection))
      end
    end

    class Unix < Base
      def initialize(path)
        super()
        @path = path
      end

      def connect
        EM.connect_unix_domain(@path, Connection, &method(:initialize_connection))
      end
    end
  end

  class Connection < EM::Connection
    attr_writer :message_callback

    def flush_message_queue(queue)
      queue.pop { |msg| send_data(msg) }
    end

    def receive_data(data)
      @message_callback.call(data)
    end
  end
end
