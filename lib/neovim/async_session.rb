require "neovim/logging"
require "neovim/request"
require "neovim/notification"

module Neovim
  # Handles formatting RPC requests and writing them to the
  # +MsgpackStream+. This exposes an asynchronous API, in which responses
  # are handled in callbacks.
  class AsyncSession
    include Logging

    def initialize(msgpack_stream)
      @msgpack_stream = msgpack_stream
      @request_id = 0
      @pending_requests = {}
    end

    # Send an RPC request and enqueue it's callback to be called when a
    # response is received.
    #
    # @param method [Symbol, String] The RPC method name
    # @param *args [Array] The arguments to the RPC method
    # @return [self]
    # @example
    #   async_session.request(:vim_strwidth, "foobar") do |response|
    #     $stderr.puts("Got a response #{response}")
    #   end
    def request(method, *args, &response_cb)
      reqid = @request_id
      @request_id += 1

      @msgpack_stream.write([0, reqid, method, args])
      @pending_requests[reqid] = response_cb || Proc.new {}
      self
    end

    # Send an RPC notification. Notifications don't receive a response
    # from +nvim+.
    #
    # @param method [Symbol, String] The RPC method name
    # @param *args [Array] The arguments to the RPC method
    # @return [self]
    # @example
    #   async_session.notify(:vim_input, "jk")
    def notify(method, *args)
      @msgpack_stream.write([2, method, args])
      self
    end

    # Run the event loop, yielding received RPC messages to the block. RPC
    # requests and notifications from +nvim+ will be wrapped in +Request+
    # and +Notification+ objects, respectively, and responses will be
    # passed to their callbacks with optional errors.
    #
    # @param session [Session] The current session
    # @yield [Object]
    # @return [void]
    # @see MsgpackStream#run
    # @see EventLoop#run
    def run(session=nil)
      @msgpack_stream.run(session) do |msg|
        kind, *rest = msg

        case kind
        when 0
          reqid, method, args = rest
          yield Request.new(method, args, @msgpack_stream, reqid) if block_given?
        when 1
          reqid, (_, error), result = rest
          @pending_requests.delete(reqid).call(error, result)
        when 2
          method, args = rest
          yield Notification.new(method, args) if block_given?
        end
      end
    rescue => e
      fatal("got unexpected error #{e}")
      debug(e.backtrace.join("\n"))
    end

    # Stop the event loop.
    #
    # @return [void]
    # @see EventLoop#stop
    def stop
      @msgpack_stream.stop
    end

    # Shut down the event loop.
    #
    # @return [void]
    # @see EventLoop#shutdown
    def shutdown
      @msgpack_stream.shutdown
    end
  end
end
