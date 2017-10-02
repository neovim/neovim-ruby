require "neovim/logging"

module Neovim
  class Session
    # Handles formatting RPC messages and registering response callbacks for
    # requests.
    #
    # @api private
    class MessageBuilder
      class Request
        attr_reader :id, :method_name, :arguments

        def initialize(id, method_name, args)
          @id = id
          @method_name = method_name.to_s
          @arguments = args
        end

        def sync?
          true
        end
      end

      class Notification
        attr_reader :method_name, :arguments

        def initialize(method_name, args)
          @method_name = method_name.to_s
          @arguments = args
        end

        def sync?
          false
        end
      end

      class Response
        attr_reader :request_id, :error

        def initialize(request_id, value, error)
          @request_id = request_id
          @value = value
          @error = error
        end

        def value
          @error ? raise(@error) : @value
        end
      end

      include Logging

      def initialize
        @request_id = 0
        @pending_requests = {}
      end

      def write(type, *write_args)
        debug("write #{type} #{write_args}")

        case type
        when :request
          method, args, response_handler = write_args
          @request_id += 1
          @pending_requests[@request_id] = response_handler

          yield [0, @request_id, method, args]
        when :response
          reqid, value, error = write_args
          yield [1, reqid, error, value]
        when :notification
          method, args = write_args
          yield [2, method, args]
        else
          raise "Unknown RPC message type #{type}"
        end
      end

      def read((kind, *payload))
        case kind
        when 0
          message = Request.new(*payload)
          debug("read #{message}")
          yield message
        when 2
          message = Notification.new(*payload)
          debug("read #{message}")
          yield message
        when 1
          reqid, (_, error), result = payload
          handler = @pending_requests.delete(reqid) || Proc.new {}
          message = Response.new(reqid, result, error)
          debug("read #{message}")
          handler.call(message)
        end
      end
    end
  end
end
