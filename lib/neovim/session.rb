require "neovim/api"
require "neovim/async_session"
require "neovim/event_loop"
require "neovim/msgpack_stream"
require "fiber"

module Neovim
  # Wraps an +AsyncSession+ in a synchronous API using +Fiber+s.
  class Session
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
      @in_handler = false
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
    # @return [self]
    # @see API
    def discover_api
      @api = API.new(request(:vim_get_api_info))
      self
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
        in_handler_fiber { yield message if block_given? }
      end

      return unless @running

      @async_session.run(self) do |message|
        in_handler_fiber { yield message if block_given? }
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
      if @in_handler
        err, res = running_request(method, *args)
      else
        err, res = stopped_request(method, *args)
      end

      err ? raise(ArgumentError, err) : res
    end

    # Make an RPC notification
    #
    # @param method [String, Symbol] The RPC method name
    # @param *args [Array] The RPC method arguments
    # @return [nil]
    def notify(method, *args)
      @async_session.notify(method, *args)
      nil
    end

    # Stop the event loop
    #
    # @return [void]
    # @see EventLoop#stop
    def stop
      @running = false
      @async_session.stop
    end

    # Shut down the event loop
    #
    # @return [void]
    # @see EventLoop#shutdown
    def shutdown
      @running = false
      @async_session.shutdown
    end

    private

    def in_handler_fiber(&block)
      Fiber.new do
        @in_handler = true
        begin
          block.call
        ensure
          @in_handler = false
        end
      end.resume
    end

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
  end
end
