require "neovim/logging"

module Neovim
  # Handles formatting RPC messages and registering response callbacks for
  # requests.
  #
  # @api private
  class Message
    def self.from_array((kind, *payload))
      case kind
      when 0
        request(*payload)
      when 1
        reqid, (_, error), value = payload
        response(reqid, error, value)
      when 2
        notification(*payload)
      else
        raise "Unknown message type #{kind.inspect}"
      end
    end

    def self.request(id, method, args)
      Request.new(id, method, args)
    end

    def self.response(request_id, error, value)
      Response.new(request_id, error, value)
    end

    def self.notification(method, args)
      Notification.new(method, args)
    end

    class Request < Struct.new(:id, :method_name, :arguments)
      def to_a
        [0, id, method_name, arguments]
      end

      def received(_, &block)
        block.call(self)
      end

      def sync?
        true
      end
    end

    class Response < Struct.new(:request_id, :error, :value)
      def to_a
        [1, request_id, error, value]
      end

      def received(handlers)
        handlers[request_id].call(self)
      end
    end

    class Notification < Struct.new(:method_name, :arguments)
      def to_a
        [2, method_name, arguments]
      end

      def received(_, &block)
        block.call(self)
      end

      def sync?
        false
      end
    end
  end
end
