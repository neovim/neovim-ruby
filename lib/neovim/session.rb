require "neovim/api"
require "neovim/async_session"
require "neovim/event_loop"
require "neovim/logging"
require "neovim/msgpack_stream"
require "fiber"

module Neovim
  # Wraps an +AsyncSession+ in a synchronous API using +Fiber+s.
  class Session
    include Logging

    # Connect to a TCP socket.
    #
    # @param host [String] The hostname or IP address
    # @param port [Fixnum] The port
    # @return [Session]
    # @see EventLoop.tcp
    def self.tcp(host, port)
      from_event_loop(EventLoop.tcp(host, port))
    end

    # Connect to a UNIX domain socket.
    #
    # @param socket_path [String] The socket path
    # @return [Session]
    # @see EventLoop.unix
    def self.unix(socket_path)
      from_event_loop(EventLoop.unix(socket_path))
    end

    # Spawn and connect to a child +nvim+ process.
    #
    # @param argv [Array] The arguments to pass to the spawned process
    # @return [Session]
    # @see EventLoop.child
    def self.child(argv)
      from_event_loop(EventLoop.child(argv))
    end

    # Connect to the current process's standard streams. This is used to
    # promote the current process to a Ruby plugin host.
    #
    # @return [Session]
    # @see EventLoop.stdio
    def self.stdio
      from_event_loop(EventLoop.stdio)
    end

    def self.from_event_loop(event_loop)
      msgpack_stream = MsgpackStream.new(event_loop)
      async_session = AsyncSession.new(msgpack_stream)
      new(async_session)
    end
    private_class_method :from_event_loop

    def initialize(async_session)
      @async_session = async_session
      @pending_messages = []
      @main_thread = Thread.current
      @main_fiber = Fiber.current
      @running = false
    end

    # Return the +nvim+ API as described in the +vim_get_api_info+ call.
    # Defaults to empty API information.
    #
    # @return [API]
    # @see API.null
    def api
      @api ||= API.null
    end

    # Discover the +nvim+ API as described in the +vim_get_api_info+ call.
    #
    # @return [API]
    # @see API
    def discover_api
      @api = API.new(request(:vim_get_api_info))
    end

    # Run the event loop, handling messages in a +Fiber+.
    #
    # @yield [Object]
    # @return [void]
    # @see AsyncSession#run
    # @see MsgpackStream#run
    # @see EventLoop#run
    def run
      @running = true

      while message = @pending_messages.shift
        Fiber.new { yield message if block_given? }.resume
      end

      return unless @running

      @async_session.run(self) do |message|
        Fiber.new { yield message if block_given? }.resume
      end
    ensure
      stop
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
    #
    # @param method [String, Symbol] The RPC method name
    # @param *args [Array] The RPC method arguments
    # @return [Object] The response from the RPC call
    # @raise [ArgumentError] An error returned from +nvim+
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

    # Make an RPC notification.
    #
    # @param method [String, Symbol] The RPC method name
    # @param *args [Array] The RPC method arguments
    # @return [nil]
    def notify(method, *args)
      main_thread_only do
        @async_session.notify(method, *args)
        nil
      end
    end

    # Stop the event loop.
    #
    # @return [void]
    # @see EventLoop#stop
    def stop
      @running = false
      @async_session.stop
    end

    # Shut down the event loop.
    #
    # @return [void]
    # @see EventLoop#shutdown
    def shutdown
      @running = false
      @async_session.shutdown
    end

    # Return the channel ID if registered via +vim_get_api_info+.
    #
    # @return [Fixnum, nil]
    def channel_id
      api.channel_id
    end

    private

    def running_request(method, *args)
      fiber = Fiber.current
      @async_session.request(method, *args) do |err, res|
        fiber.resume(err, res)
      end
      Fiber.yield
    end

    def stopped_request(method, *args)
      error, result = nil

      @async_session.request(method, *args) do |err, res|
        error, result = err, res
        stop
      end.run(self) do |message|
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
