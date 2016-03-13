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

    def request(method, *args, &response_cb)
      reqid = @request_id
      @request_id += 1

      @msgpack_stream.send([0, reqid, method, args])
      @pending_requests[reqid] = response_cb
      self
    end

    def notify(method, *args)
      @msgpack_stream.send([2, method, args])
      self
    end

    def run(session=nil, &message_cb)
      message_cb ||= Proc.new {}

      @msgpack_stream.run(session) do |msg|
        kind, *rest = msg

        case kind
        when 0
          reqid, method, args = rest
          message_cb.call(Request.new(method, args, @msgpack_stream, reqid))
        when 1
          reqid, (_, error), result = rest
          @pending_requests.fetch(reqid).call(error, result)
        when 2
          method, args = rest
          message_cb.call(Notification.new(method, args))
        end
      end
    rescue => e
      fatal("got unexpected error #{e}")
      debug(e.backtrace.join("\n"))
    end

    def stop
      @msgpack_stream.stop
    end
  end
end
