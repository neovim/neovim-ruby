require "neovim/logging"
require "neovim/session/connection"
require "neovim/session/rpc"
require "neovim/session/serializer"

module Neovim
  class Session
    class EventLoop
      include Logging

      def initialize(connection)
        @running = false
        @shutdown = false
        @connection = connection
        @serializer = Serializer.new
        @rpc = RPC.new
        @rpc_writers = []
      end

      def stop
        @running = false
      end

      def shutdown
        stop
        @shutdown = true
      end

      def request(method, *args, &response_handler)
        enqueue_rpc_writer(:request, method, args, response_handler)
      end

      def respond(request_id, return_value, error)
        enqueue_rpc_writer(:response, request_id, return_value, error)
      end

      def notify(method, *args)
        enqueue_rpc_writer(:notification, method, args)
      end

      def run(&callback)
        @running = true

        loop do
          break if !@running
          break if @shutdown

          while writer = @rpc_writers.shift
            writer.call
          end

          @connection.read do |bytes|
            @serializer.read(bytes) do |obj|
              @rpc.read(obj, &callback)
            end
          end
        end
      rescue EOFError
        info("got EOFError")
      rescue => e
        fatal("got unexpected error #{e.inspect}")
        debug(e.backtrace.join("\n"))
      ensure
        @connection.close if @shutdown
      end

      # Register msgpack ext types using the provided API and session
      def register_types(api, session)
        info("registering msgpack ext types")
        api.types.each do |type, info|
          id = info.fetch("id")
          klass = Neovim.const_get(type)

          @serializer.register_type(id) do |index|
            klass.new(index, session)
          end
        end
      end

      private

      def enqueue_rpc_writer(type, *args)
        @rpc_writers << Proc.new do
          debug("writing rpc #{type} #{args}")

          @rpc.write(type, *args) do |arr|
            @serializer.write(arr) do |bytes|
              @connection.write(bytes)
            end
          end
        end
      end
    end
  end
end
