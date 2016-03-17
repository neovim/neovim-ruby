require "neovim/api_info"
require "fiber"

module Neovim
  class Session
    def initialize(async_session)
      @async_session = async_session
      @pending_messages = []
      @in_handler = false
    end

    def api
      @api ||= APIInfo.null
    end

    def discover_api
      @api = APIInfo.new(request(:vim_get_api_info))
      self
    end

    def run(&message_cb)
      message_cb ||= Proc.new {}

      while message = @pending_messages.shift
        in_handler_fiber { message_cb.call(message) }
      end

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

    def stop
      @handler_fiber = nil
      @async_session.stop
    end
  end
end
