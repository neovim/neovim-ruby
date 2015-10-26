module Neovim
  class Request
    attr_reader :method_name, :arguments

    def initialize(method_name, args, msgpack_stream, request_id)
      @method_name = method_name
      @arguments = args
      @msgpack_stream = msgpack_stream
      @request_id = request_id
    end

    def respond(value)
      @msgpack_stream.send([1, @request_id, nil, value])
      self
    end

    def error(message)
      @msgpack_stream.send([1, @request_id, message, nil])
      self
    end
  end
end
