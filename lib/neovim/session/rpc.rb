require "neovim/logging"
require "neovim/request"
require "neovim/notification"

module Neovim
  class Session
    # Handles formatting RPC requests and writing them to the +Serializer+.
    # This exposes an asynchronous API, in which responses are handled in
    # callbacks.
    #
    # @api private
    class RPC
      include Logging

      attr_reader :serializer

      def initialize(serializer)
        @serializer = serializer
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
      #   rpc.request(:vim_strwidth, "foobar") do |response|
      #     $stderr.puts("Got a response #{response}")
      #   end
      def request(method, *args, &response_cb)
        reqid = @request_id
        @request_id += 1

        @serializer.write([0, reqid, method, args])
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
      #   rpc.notify(:vim_input, "jk")
      def notify(method, *args)
        @serializer.write([2, method, args])
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
      # @see Serializer#run
      # @see EventLoop#run
      def run(&callback)
        @serializer.run do |msg|
          debug("received #{msg.inspect}")
          kind, *payload = msg

          case kind
          when 0
            handle_request(payload, callback)
          when 1
            handle_response(payload)
          when 2
            handle_notification(payload, callback)
          end
        end
      rescue => e
        fatal("got unexpected error #{e.inspect}")
        debug(e.backtrace.join("\n"))
      end

      # Stop the event loop.
      #
      # @return [void]
      # @see EventLoop#stop
      def stop
        @serializer.stop
      end

      # Shut down the event loop.
      #
      # @return [void]
      # @see EventLoop#shutdown
      def shutdown
        @serializer.shutdown
      end

      private

      def handle_request(payload, callback)
        callback ||= Proc.new {}
        reqid, method, args = payload
        callback.call(Request.new(method, args, @serializer, reqid))
      end

      def handle_response(payload)
        reqid, (_, error), result = payload
        callback = @pending_requests.delete(reqid) || Proc.new {}
        callback.call(error, result)
      end

      def handle_notification(payload, callback)
        callback ||= Proc.new {}
        method, args = payload
        callback.call(Notification.new(method, args))
      end
    end
  end
end
