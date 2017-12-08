require "neovim/logging"
require "fiber"

module Neovim
  # Wraps an event loop in a synchronous API using +Fiber+s.
  #
  # @api private
  class Session
    include Logging

    attr_writer :request_id

    def initialize(event_loop)
      @event_loop = event_loop
      @main_thread = Thread.current
      @main_fiber = Fiber.current
      @response_handlers = Hash.new(Proc.new {})
      @pending_messages = []
      @request_id = 0
    end

    # Run the event loop, handling messages in a +Fiber+.
    def run(&block)
      @running = true

      while message = @pending_messages.shift
        Fiber.new { message.received(@response_handlers, &block) }.resume
      end

      return unless @running

      @event_loop.run do |message|
        Fiber.new { message.received(@response_handlers, &block) }.resume
      end
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
        @request_id += 1
        blocking = Fiber.current == @main_fiber

        log(:debug) do
          {
            :method_name => method,
            :request_id => @request_id,
            :blocking => blocking,
            :arguments => args
          }
        end

        @event_loop.request(@request_id, method, *args)
        response = blocking ? blocking_response : yielding_response
        response.error ? raise(response.error) : response.value
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

    def blocking_response
      response = nil

      @response_handlers[@request_id] = Proc.new do |res|
        response = res
        stop
      end

      run { |message| @pending_messages << message }
      response
    end

    def yielding_response
      fiber = Fiber.current

      @response_handlers[@request_id] = Proc.new do |response|
        fiber.resume(response)
      end

      Fiber.yield
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
