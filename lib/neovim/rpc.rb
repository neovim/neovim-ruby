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
      return nil unless response = stream.read

      MessagePack.unpack(response).tap do |payload|
        if error_msg = payload[2]
          raise Error.new(error_msg)
        end
      end
    end
  end
end
