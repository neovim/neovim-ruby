require "neovim/logging"
require "neovim/session/api"
require "neovim/session/event_loop"
require "neovim/session/rpc"
require "neovim/session/serializer"
require "fiber"

module Neovim
  # Wraps a +Session::RPC+ in a synchronous API using +Fiber+s.
  #
  # @api private
  class Session
    include Logging

    # Connect to a TCP socket.
    def self.tcp(host, port)
      from_event_loop(EventLoop.tcp(host, port))
    end

    # Connect to a UNIX domain socket.
    def self.unix(socket_path)
      from_event_loop(EventLoop.unix(socket_path))
    end

    # Spawn and connect to a child +nvim+ process.
    def self.child(argv)
      from_event_loop(EventLoop.child(argv))
    end

    # Connect to the current process's standard streams. This is used to
    # promote the current process to a Ruby plugin host.
    def self.stdio
      from_event_loop(EventLoop.stdio)
    end

    def self.from_event_loop(event_loop)
      serializer = Serializer.new(event_loop)
      rpc = RPC.new(serializer)
      new(rpc)
    end
    private_class_method :from_event_loop

    def initialize(rpc)
      @rpc = rpc
      @pending_messages = []
      @main_thread = Thread.current
      @main_fiber = Fiber.current
      @running = false
    end

    # Return the +nvim+ API as described in the +nvim_get_api_info+ call.
    # Defaults to empty API information.
    def api
      @api ||= API.null
    end

    # Discover the +nvim+ API as described in the +nvim_get_api_info+ call,
    # propagating it down to lower layers of the stack.
    def discover_api
      @api = API.new(request(:nvim_get_api_info)).tap do |api|
        @rpc.serializer.register_types(api, self)
      end
    end

    # Run the event loop, handling messages in a +Fiber+.
    def run
      @running = true

      while pending = @pending_messages.shift
        Fiber.new { yield pending if block_given? }.resume
      end

      return unless @running

      @rpc.run do |message|
        Fiber.new { yield message if block_given? }.resume
      end
    ensure
      shutdown
    end

    # Make an RPC request and return its response.
    #
    # If this method is called inside a callback, we are already inside a
    # +Fiber+ handler. In that case, we write to the stream and yield the
    # +Fiber+. Once the response is received, resume the +Fiber+ and
    # return the result.
    #
    # If this method is called outside a callback, write to the stream and
    # run the event loop until a response is received. Messages received
    # in the meantime are enqueued to be handled later.
    def request(method, *args)
      main_thread_only do
        if Fiber.current == @main_fiber
          debug("handling blocking request")
          err, res = stopped_request(method, *args)
        else
          debug("yielding request to fiber")
          err, res = running_request(method, *args)
        end

        err ? raise(ArgumentError, err) : res
      end
    end

    # Make an RPC notification. +nvim+ will not block waiting for a response.
    def notify(method, *args)
      main_thread_only do
        @rpc.notify(method, *args)
        nil
      end
    end

    # Return the channel ID if registered via +nvim_get_api_info+.
    def channel_id
      api.channel_id
    end

    def stop
      @running = false
      @rpc.stop
    end

    def shutdown
      @running = false
      @rpc.shutdown
    end

    private

    def running_request(method, *args)
      fiber = Fiber.current
      @rpc.request(method, *args) do |err, res|
        fiber.resume(err, res)
      end
      Fiber.yield
    end

    def stopped_request(method, *args)
      error, result = nil

      @rpc.request(method, *args) do |err, res|
        error, result = err, res
        stop
      end.run do |message|
        @pending_messages << message
      end

      [error, result]
    end

    def main_thread_only
      if Thread.current == @main_thread
        yield if block_given?
      else
        raise(
          "A Ruby plugin attempted to call neovim outside of the main thread, " +
          "which is not yet supported by the neovim gem."
        )
      end
    end
  end
end
