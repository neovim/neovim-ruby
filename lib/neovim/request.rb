module Neovim
  # A synchronous message from +nvim+.
  # @api private
  class Request
    attr_reader :method_name, :arguments

    def initialize(method_name, args, msgpack_stream, request_id)
      @method_name = method_name.to_s
      @arguments = args
      @msgpack_stream = msgpack_stream
      @request_id = request_id
    end

    def sync?
      true
    end

    def respond(value)
      @msgpack_stream.write([1, @request_id, nil, value])
      self
    end

    def error(message)
      @msgpack_stream.write([1, @request_id, message, nil])
      self
    end
  end
end
