require "neovim/stream"
require "neovim/rpc"
require "neovim/variable"
require "neovim/scope"
require "neovim/option"

require "msgpack"

module Neovim
  class Client
    def initialize(address)
      address, port = address.split(":")
      @stream = Stream.new(address, port)
      @req_id = 0

      @plugin_id, defs = discover_api
      @method_lookup = create_method_lookup(defs["functions"])
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

    def buffers
      rpc_response(:vim_get_buffers).map do |index|
        Buffer.new(index, self)
      end
    end

    def current_buffer
      index = rpc_response(:vim_get_current_buffer)
      Buffer.new(index, self)
    end

    def current_line
      rpc_response(:vim_get_current_line)
    end

    def current_line=(line)
      rpc_response(:vim_set_current_line, line)
    end

    def windows
      rpc_response(:vim_get_windows).map do |window_index|
        Window.new(window_index, self)
      end
    end

    def current_window
      window_index = rpc_response(:vim_get_current_window)
      Window.new(window_index, self)
    end

    def current_window=(window_index)
      rpc_response(:vim_set_current_window, window_index)
    end

    def tabpages
      rpc_response(:vim_get_tabpages).map do |tabpage_index|
        Tabpage.new(tabpage_index, self)
      end
    end

    def current_tabpage
      tabpage_index = rpc_response(:vim_get_current_tabpage)
      Tabpage.new(tabpage_index, self)
    end

    def current_tabpage=(tabpage_index)
      rpc_response(:vim_set_current_tabpage, tabpage_index)
    end

    def variable(name)
      scope = Scope::Global.new
      Variable.new(name, scope, self)
    end

    def builtin_variable(name)
      scope = Scope::Builtin.new
      Variable.new(name, scope, self)
    end

    def option(name)
      scope = Scope::Global.new
      Option.new(name, scope, self)
    end

    def rpc_response(method_name, *args)
      begin
        rpc(method_name, *args).response[3]
      rescue EOFError
        # Neovim was killed by the rpc
      end
    end

    private

    def rpc(method_name, *args)
      method_id = @method_lookup.fetch(method_name)
      data = [0, @req_id += 1, method_id, args]
      RPC.new(data, @stream)
    end

    def discover_api
      rpc_response = RPC.new([0, 0, 0, []], @stream).response
      plugin_id, encoded_api = rpc_response[3]
      [plugin_id, MessagePack.unpack(encoded_api)]
    end

    def create_method_lookup(defs)
      defs.inject({}) do |acc, mdef|
        acc.merge(mdef["name"].to_sym => mdef["id"])
      end
    end
  end
end
