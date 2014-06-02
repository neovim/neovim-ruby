require "neovim/stream"
require "neovim/rpc"
require "neovim/variable"
require "neovim/option"

require "msgpack"

module Neovim
  class Client
    def initialize(address)
      address, port = address.split(":")
      @stream = Stream.new(address, port)
      @req_id = 0

      @plugin_id, defs = discover_api
      @method_lookup = defs["functions"].inject({}) do |acc, mdef|
        acc.merge(mdef["name"].to_sym => mdef["id"])
      end
    end

    def message(msg)
      rpc_response(:vim_out_write, msg)
    end

    def error(msg)
      rpc_response(:vim_err_write, msg)
    end

    def command(cmd)
      rpc_response(:vim_command, cmd)
    end

    def commands(*cmds)
      rpc_response(:vim_command, cmds.join(" | "))
    end

    def evaluate(expr)
      rpc_response(:vim_eval, expr)
    end

    def push_keys(keys)
      rpc_response(:vim_push_keys, keys)
    end

    def strwidth(str)
      rpc_response(:vim_strwidth, str)
    end

    def runtime_paths
      rpc_response(:vim_list_runtime_paths)
    end

    def change_directory(dir)
      rpc_response(:vim_change_directory, dir)
    end

    def current_line
      rpc_response(:vim_get_current_line)
    end

    def current_line=(line)
      rpc_response(:vim_set_current_line, line)
    end

    def variable(name)
      Variable.new(name, self)
    end

    def option(name)
      Option.new(name, self)
    end

    def rpc_response(method_name, *args)
      method_id = @method_lookup.fetch(method_name)
      data = [0, @req_id += 1, method_id, args]
      RPC.new(data, @stream).response[3]
    end

    private

    def discover_api
      response = RPC.new([0, 0, 0, []], @stream).response
      plugin_id, encoded_api = response[3]
      [plugin_id, MessagePack.unpack(encoded_api)]
    end
  end
end
