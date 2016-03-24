require "neovim/api"
require "fiber"

module Neovim
  class Session
    def self.tcp(host, port)
      from_event_loop(EventLoop.tcp(host, port))
    end

    def self.unix(socket_path)
      from_event_loop(EventLoop.unix(socket_path))
    end

    def self.child(argv)
      from_event_loop(EventLoop.child(argv))
    end

    def self.stdio
      from_event_loop(EventLoop.stdio)
    end

    def self.from_event_loop(event_loop)
      msgpack_stream = MsgpackStream.new(event_loop)
      async_session = AsyncSession.new(msgpack_stream)
      new(async_session)
    end

    def initialize(async_session)
      @async_session = async_session
      @pending_messages = []
      @in_handler = false
      @running = false
    end

    def api
      @api ||= API.null
    end

    def discover_api
      @api = API.new(request(:vim_get_api_info))
      self
    end

    def run(&message_cb)
      @running = true
      message_cb ||= Proc.new {}

      while message = @pending_messages.shift
        in_handler_fiber { message_cb.call(message) }
      end

      return unless @running

      @async_session.run(self) do |message|
        in_handler_fiber { message_cb.call(message) }
      end
    ensure
      stop
    end

    def request(method, *args)
      if @in_handler
        err, res = running_request(method, *args)
      else
        err, res = stopped_request(method, *args)
      end

      err ? raise(ArgumentError, err) : res
    end

    def notify(method, *args)
      @async_session.notify(method, *args)
      nil
    end

    def stop
      @running = false
      @async_session.stop
    end

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
