require "neovim/logging"
require "neovim/connection"
require "neovim/message"

module Neovim
  # @api private
  class EventLoop
    include Logging

    def self.tcp(host, port)
      new Connection.tcp(host, port)
    end

    def self.unix(path)
      new Connection.unix(path)
    end

    def self.child(argv)
      new Connection.child(argv)
    end

    def self.stdio
      new Connection.stdio
    end

    def initialize(connection)
      @running = false
      @shutdown = false
      @connection = connection
    end

    def stop
      @running = false
    end

    def shutdown
      @running = false
      @shutdown = true
      @connection.close
    end

    def request(request_id, method, *args)
      log(:debug) do
        {
          request_id: request_id,
          method: method,
          arguments: args
        }
      end

      write(:request, request_id, method, args)
    end

    def respond(request_id, return_value, error)
      log(:debug) do
        {
          request_id: request_id,
          return_value: return_value,
          error: error
        }
      end

      write(:response, request_id, error, return_value)
    end

    def notify(method, *args)
      log(:debug) { {name: method, arguments: args} }
      write(:notification, method, args)
    end

    def run
      @running = true
      last_value = nil

      loop do
        break unless @running
        break if @shutdown

        begin
          last_value = yield(read)
        rescue EOFError, Errno::EPIPE => e
          log_exception(:debug, e, __method__)
          shutdown
        rescue => e
          log_exception(:error, e, __method__)
        end
      end

      last_value
    ensure
      @connection.close if @shutdown
    end

    def register_types(api, session)
      api.types.each do |type, info|
        id = info.fetch("id")
        klass = Neovim.const_get(type)
        log(:debug) { {type: type, id: id} }

        @connection.register_type(id) do |index|
          klass.new(index, session, api)
        end
      end
    end

    private

    def read
      array = @connection.flush.read
      Message.from_array(array)
    end

    def write(type, *args)
      message = Message.public_send(type, *args)
      @connection.write(message.to_a)
    end
  end
end
