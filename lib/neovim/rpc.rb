require "msgpack"

module Neovim
  class RPC
    attr_reader :response

    def initialize(data, stream)
      message = MessagePack.pack(data)
      stream.write(message)
      @response = MessagePack.unpack(stream.read)
    end
  end
end
