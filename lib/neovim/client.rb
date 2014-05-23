require "neovim/stream"
require "neovim/rpc"
require "neovim/variable"
require "neovim/option"

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

    def error(msg)
      rpc_response(35, msg)
    end

    def set_option(option, value)
      rpc_response(34, option, value)
    end

    def command(cmd)
      rpc_response(22, cmd)
    end

    def evaluate(expr)
      rpc_response(23, expr)
    end

    def push_keys(keys)
      rpc_response(21, keys)
    end

    def strwidth(str)
      rpc_response(24, str)
    end

    def runtime_paths
      rpc_response(25)
    end

    def change_directory(dir)
      rpc_response(26, dir)
    end

    def current_line
      rpc_response(27)
    end

    def current_line=(line)
      rpc_response(29, line)
    end

    def variable(name)
      Variable.new(name, self)
    end

    def option(name)
      Option.new(name, self)
    end

    def rpc_response(func_id, *args)
      data = [0, @req_id += 1, func_id, args]
      RPC.new(data, @stream).response[3]
    end
  end
end
