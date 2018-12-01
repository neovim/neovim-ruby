require "neovim/logging"

module Neovim
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

    Request = Struct.new(:id, :method_name, :arguments) do
      def to_a
        [0, id, method_name, arguments]
      end

      def received(_)
        yield self
      end

      def sync?
        true
      end
    end

    Response = Struct.new(:request_id, :error, :value) do
      def to_a
        [1, request_id, error, value]
      end

      def received(handlers)
        handlers.delete(request_id).call(self)
      end
    end

    Notification = Struct.new(:method_name, :arguments) do
      def to_a
        [2, method_name, arguments]
      end

      def received(_)
        yield self
      end

      def sync?
        false
      end
    end
  end
end
