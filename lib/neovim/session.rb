require "neovim/api_info"
require "fiber"

module Neovim
  class Session
    def initialize(async_session)
      @async_session = async_session
      @pending_messages = []
      @running = false
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

      until @pending_messages.empty?
        in_handler_fiber { message_cb.call(@pending_messages.shift) }
      end

      @async_session.run(self) do |message|
        in_handler_fiber { message_cb.call(message) }
        STDERR.puts("AFTER")
      end
    ensure
      stop
    end

    def request(method, *args)
      if @handler_fiber
        err, res = running_request(method, *args)
      else
        err, res = stopped_request(method, *args)
      end

      err ? raise(ArgumentError, err) : res
    end

    private

    def in_handler_fiber(&block)
      @handler_fiber = Fiber.new(&block)
      @handler_fiber.resume
    end

    def running_request(method, *args)
      Fiber.new do
        @async_session.request(method, *args) do |err, res|
          STDERR.puts("BEFORE")
          @handler_fiber.transfer(err, res)
        end
      end.transfer
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
