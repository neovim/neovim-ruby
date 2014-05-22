require "msgpack"

module Neovim
  class RPC
    class Error < RuntimeError; end

    attr_reader :response

    def initialize(data, stream)
      @response = fetch_response(data, stream)
    end

    private

    def fetch_response(data, stream)
      stream.write(MessagePack.pack(data))

      MessagePack.unpack(stream.read).tap do |payload|
        raise Error if payload[2]
      end
    end
  end
end
