require "neovim/logging"
require "neovim/request"
require "neovim/notification"

module Neovim
  class AsyncSession
    include Logging

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

      msg_cb = Proc.new do |msg|
        kind, *rest = msg

        case kind
        when 0
          reqid, method, args = rest
          request_cb.call(Request.new(method, args, @msgpack_stream, reqid))
        when 1
          reqid, (_, error), result = rest
          @pending_requests.fetch(reqid).call(error, result)
        when 2
          method, args = rest
          notification_cb.call(Notification.new(method, args))
        end
      end

      @msgpack_stream.run(msg_cb)
    rescue => e
      fatal("got unexpected error #{e}")
      debug(e.backtrace.join("\n"))
    end

    def stop
      @msgpack_stream.stop
    end
  end
end
