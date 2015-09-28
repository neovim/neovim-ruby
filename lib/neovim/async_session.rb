module Neovim
  class AsyncSession
    def initialize(msgpack_stream)
      @msgpack_stream = msgpack_stream
      @request_id = 0
      @pending_requests = {}
    end

    def register_session(session)
      @msgpack_stream.register_session(session)
    end

    def request(method, *args, &response_cb)
      reqid = @request_id
      @request_id += 1

      @msgpack_stream.send([0, reqid, method, args])
      @pending_requests[reqid] = response_cb || Proc.new {}
      self
    end

    def notify(method, *args)
      @msgpack_stream.send([2, method, args])
      self
    end

    def run(request_cb=nil, notification_cb=nil)
      request_cb ||= Proc.new {}
      notification_cb ||= Proc.new {}

      @msgpack_stream.run do |msg|
        kind, *rest = msg

        case kind
        when 0
          reqid, method, args = rest
          request_cb.call(method, args, Responder.new(@msgpack_stream, reqid))
        when 1
          reqid, (_, error), result = rest
          @pending_requests.fetch(reqid).call(error, result)
        when 2
          event, args = rest
          notification_cb.call(event, args)
        end
      end
    end

    def stop
      @msgpack_stream.stop
      self
    end

    def shutdown
      @msgpack_stream.shutdown
      self
    end

    class Responder
      def initialize(msgpack_stream, request_id)
        @msgpack_stream = msgpack_stream
        @request_id = request_id
      end

      def send(value)
        @msgpack_stream.send([1, @request_id, nil, value])
        self
      end

      def error(value)
        @msgpack_stream.send([1, @request_id, value, nil])
        self
      end
    end
  end
end
