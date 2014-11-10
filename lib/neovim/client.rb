require "neovim/rpc"
require "neovim/variable"
require "neovim/scope"
require "neovim/option"

module Neovim
  class Client
    def initialize(io)
      @rpc = RPC.new(io)
    end

    def message(msg)
      rpc_send(:vim_out_write, msg)
    end

    def error(msg)
      rpc_send(:vim_err_write, msg)
    end

    def command(cmd)
      rpc_send(:vim_command, cmd)
    end

    def evaluate(expr)
      rpc_send(:vim_eval, expr)
    end

    def push_keys(keys)
      rpc_send(:vim_push_keys, keys)
    end

    def strwidth(str)
      rpc_send(:vim_strwidth, str)
    end

    def runtime_paths
      rpc_send(:vim_list_runtime_paths)
    end

    def change_directory(dir)
      rpc_send(:vim_change_directory, dir)
    end

    def buffers
      rpc_send(:vim_get_buffers).map do |index|
        Buffer.new(index, self)
      end
    end

    def current_buffer
      index = rpc_send(:vim_get_current_buffer)
      Buffer.new(index, self)
    end

    def current_line
      rpc_send(:vim_get_current_line)
    end

    def current_line=(line)
      rpc_send(:vim_set_current_line, line)
    end

    def windows
      rpc_send(:vim_get_windows).map do |window_index|
        Window.new(window_index, self)
      end
    end

    def current_window
      window_index = rpc_send(:vim_get_current_window)
      Window.new(window_index, self)
    end

    def current_window=(window_index)
      rpc_send(:vim_set_current_window, window_index)
    end

    def tabpages
      rpc_send(:vim_get_tabpages).map do |tabpage_index|
        Tabpage.new(tabpage_index, self)
      end
    end

    def current_tabpage
      tabpage_index = rpc_send(:vim_get_current_tabpage)
      Tabpage.new(tabpage_index, self)
    end

    def current_tabpage=(tabpage_index)
      rpc_send(:vim_set_current_tabpage, tabpage_index)
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

    def rpc_send(method_name, *args)
      @rpc.send(method_name, *args).response
    end
  end
end
