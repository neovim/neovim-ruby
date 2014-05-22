require "neovim/stream"
require "neovim/rpc"

module Neovim
  class Client
    def initialize(address)
      address, port = address.split(":")
      @stream = Stream.new(address, port)
      @req_id = 0
    end

    def message(msg)
      rpc_response(36, msg)
    end

    def set_option(option, arg)
      rpc_response(34, option, arg)
    end

    def command(cmd)
      rpc_response(22, cmd)
    end

    def evaluate(expr)
      rpc_response(23, expr)
    end

    private

    def rpc_response(func_id, *args)
      data = [0, @req_id += 1, func_id, args]
      RPC.new(data, @stream).response[3]
    end
  end
end
