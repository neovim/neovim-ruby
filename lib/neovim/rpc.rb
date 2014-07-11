require "msgpack"

module Neovim
  class RPC
    class Error < RuntimeError; end

    def initialize(stream)
      @stream = stream
    end

    def write(data)
      packed_data = MessagePack.pack(data)
      packed_response = @stream.write(packed_data).read

      MessagePack.unpack(packed_response).tap do |payload|
        if error_msg = payload[2]
          raise Error.new(error_msg)
        end
      end
    end
  end
end
