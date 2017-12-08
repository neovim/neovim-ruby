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

        def received(_, &block)
          block.call(self)
        end

        def sync?
          true
        end

        def to_h
          super.merge(:type => :request)
        end
      end

      class Notification < Struct.new(:method_name, :arguments)
        include StructToH

        def received(_, &block)
          block.call(self)
        end

        def sync?
          false
        end

        def to_h
          super.merge(:type => :notification)
        end
      end

      class Response < Struct.new(:request_id, :error, :value)
        include StructToH

        def received(handlers)
          handlers[request_id].call(self)
        end

        def to_h
          super.merge(:type => :response)
        end
      end

      include Logging

      def write(type, *write_args)
        case type
        when :request
          reqid, method, args = write_args

          log(:debug) do
            {
              :type => type,
              :request_id => reqid,
              :method_name => method,
              :arguments => args,
            }
          end

          yield [0, reqid, method, args]
        when :response
          reqid, value, error = write_args

          log(:debug) do
            {
              :type => type,
              :request_id => reqid,
              :value => value,
              :error => error,
            }
          end

          yield [1, reqid, error, value]
        when :notification
          method, args = write_args

          log(:debug) do
            {
              :type => type,
              :method_name => method,
              :arguments => args,
            }
          end

          yield [2, method, args]
        else
          raise "Unknown RPC message type #{type}"
        end
      end

      def read((kind, *payload))
        case kind
        when 0
          message = Request.new(*payload)
        when 1
          reqid, (_, error), value = payload
          message = Response.new(reqid, error, value)
        when 2
          message = Notification.new(*payload)
        else
          raise "Received unknown message type #{kind.inspect}"
        end

        log(:debug) { message.to_h }
        yield message
      end
    end
  end
end
