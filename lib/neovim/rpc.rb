require "msgpack"

module Neovim
  class RPC
    class Error < RuntimeError; end

    attr_reader :response

    def initialize(data, stream)
      @data = data
      @stream = stream
      @stream.write(MessagePack.pack(@data))
    end

    def response
      @response ||= fetch_response
    end

    private

    def fetch_response
      raw_response = @stream.read
      MessagePack.unpack(raw_response).tap do |payload|
        if error_msg = payload[2]
          raise Error.new(error_msg)
        end
      end
    end
  end
end
