require "neovim/logging"
require "neovim/api"
require "fiber"

module Neovim
  # Wraps an event loop in a synchronous API using +Fiber+s.
  #
  # @api private
  class Session
    include Logging

    def initialize(event_loop)
      @event_loop = event_loop
      @pending_messages = []
      @main_thread = Thread.current
      @main_fiber = Fiber.current
    end

    # Run the event loop, handling messages in a +Fiber+.
    def run
      @running = true

      while pending = @pending_messages.shift
        Fiber.new { yield pending if block_given? }.resume
      end

      return unless @running

      @event_loop.run do |message|
        Fiber.new { yield message if block_given? }.resume
      end
    ensure
      @event_loop.shutdown
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
          response = blocking_request(method, *args)
        else
          debug("yielding request to fiber")
          response = yielding_request(method, *args)
        end

        response.value
      end
    end

    def respond(request_id, value, error=nil)
      @event_loop.respond(request_id, value, error)
    end

    # Make an RPC notification. +nvim+ will not block waiting for a response.
    def notify(method, *args)
      @event_loop.notify(method, *args)
    end

    def shutdown
      @running = false
      @event_loop.shutdown
    end

    def stop
      @running = false
      @event_loop.stop
    end

    private

    def yielding_request(method, *args)
      fiber = Fiber.current
      @event_loop.request(method, *args) do |response|
        fiber.resume(response)
      end
      Fiber.yield
    end

    def blocking_request(method, *args)
      response = nil

      @event_loop.request(method, *args) do |res|
        response = res
        stop
      end

      @event_loop.run do |message|
        @pending_messages << message
      end

      response
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
