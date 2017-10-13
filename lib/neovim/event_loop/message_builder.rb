require "neovim/logging"

module Neovim
  class EventLoop
    # Handles formatting RPC messages and registering response callbacks for
    # requests.
    #
    # @api private
    class MessageBuilder
      module StructToH
        def to_h
          each_pair.inject({}) { |acc, (k, v)| acc.merge(k => v) }
        end
      end

      class Request < Struct.new(:id, :method_name, :arguments)
        include StructToH

        def sync?
          true
        end

        def to_h
          super.merge(:type => :request)
        end
      end

      class Notification < Struct.new(:method_name, :arguments)
        include StructToH

        def sync?
          false
        end

        def to_h
          super.merge(:type => :notification)
        end
      end

      class Response < Struct.new(:request_id, :value, :error)
        include StructToH

        def value!
          error ? raise(error) : value
        end

        def to_h
          super.merge(:type => :response)
        end
      end

      include Logging

      def initialize
        @request_id = 0
        @pending_requests = {}
      end

      def write(type, *write_args)
        case type
        when :request
          method, args, response_handler = write_args

          @request_id += 1
          @pending_requests[@request_id] = response_handler

          log(
            :debug,
            __method__,
            :type => type,
            :request_id => @request_id,
            :method_name => method,
            :arguments => args,
          )

          yield [0, @request_id, method, args]
        when :response
          reqid, value, error = write_args

          log(
            :debug,
            __method__,
            :type => type,
            :request_id => reqid,
            :value => value,
            :error => error,
          )

          yield [1, reqid, error, value]
        when :notification
          method, args = write_args

          log(
            :debug,
            __method__,
            :type => type,
            :method_name => method,
            :arguments => args,
          )

          yield [2, method, args]
        else
          raise "Unknown RPC message type #{type}"
        end
      end

      def read((kind, *payload))
        case kind
        when 0
          message = Request.new(*payload)
          log(:debug, __method__, message.to_h)
          yield message
        when 2
          message = Notification.new(*payload)
          log(:debug, __method__, message.to_h)
          yield message
        when 1
          reqid, (_, error), result = payload
          handler = @pending_requests.delete(reqid) || Proc.new {}
          message = Response.new(reqid, result, error)
          log(:debug, __method__, message.to_h)
          handler.call(message)
        end
      end
    end
  end
end
