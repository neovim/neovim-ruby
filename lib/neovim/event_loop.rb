require "neovim/logging"
require "neovim/event_loop/connection"
require "neovim/event_loop/message_builder"

module Neovim
  class EventLoop
    include Logging

    # Connect to a TCP socket.
    def self.tcp(host, port)
      new Connection.tcp(host, port)
    end

    # Connect to a UNIX domain socket.
    def self.unix(path)
      new Connection.unix(path)
    end

    # Spawn and connect to a child +nvim+ process.
    def self.child(argv)
      new Connection.child(argv)
    end

    # Connect to the current process's standard streams. This is used to
    # promote the current process to a Ruby plugin host.
    def self.stdio
      new Connection.stdio
    end

    def initialize(connection)
      @running = false
      @shutdown = false
      @connection = connection
      @message_builder = MessageBuilder.new
    end

    def stop
      @running = false
    end

    def shutdown
      stop
      @shutdown = true
    end

    def request(method, *args, &response_handler)
      log(:debug) { {:name => method, :arguments => args} }
      write(:request, method, args, response_handler)
    end

    def respond(request_id, return_value, error)
      log(:debug) do
        {
          :request_id => request_id,
          :return_value => return_value,
          :error => error
        }
      end

      write(:response, request_id, return_value, error)
    end

    def notify(method, *args)
      log(:debug) { {:name => method, :arguments => args} }
      write(:notification, method, args)
    end

    def run(&callback)
      @running = true

      loop do
        break if !@running
        break if @shutdown

        begin
          @connection.read do |obj|
            @message_builder.read(obj, &callback)
          end
        rescue EOFError, SignalException => e
          log_exception(:debug, e, __method__)
          shutdown
        rescue => e
          log_exception(:error, e, __method__)
        end
      end
    ensure
      @connection.close if @shutdown
    end

    # Register msgpack ext types using the provided API and session
    def register_types(api, session)
      api.types.each do |type, info|
        id = info.fetch("id")
        klass = Neovim.const_get(type)
        log(:debug) { {:type => type, :id => id} }

        @connection.register_type(id) do |index|
          klass.new(index, session, api)
        end
      end
    end

    private

    def write(type, *args)
      @message_builder.write(type, *args) do |arr|
        @connection.write(arr)
      end
    end
  end
end
