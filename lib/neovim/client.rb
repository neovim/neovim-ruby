require "neovim/buffer"
require "neovim/option"
require "neovim/rpc"
require "neovim/scope"
require "neovim/tabpage"
require "neovim/variable"
require "neovim/window"

module Neovim
  class Client
    def initialize(io)
      @rpc = RPC.new(io)
      @id, @api = rpc_send(:vim_get_api_info)
    end

    def type_code(klass)
      unqualified = klass.to_s.split("::").last
      types.fetch(unqualified).fetch("id")
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
      rpc_send(:vim_get_buffers).map do |buffer|
        buffer_index = buffer.data.unpack("c*").first
        Buffer.new(buffer_index, self)
      end
    end

    def current_buffer
      buffer = rpc_send(:vim_get_current_buffer)
      buffer_index = buffer.data.unpack("c*").first
      Buffer.new(buffer_index, self)
    end

    def current_line
      rpc_send(:vim_get_current_line)
    end

    def current_line=(line)
      rpc_send(:vim_set_current_line, line)
    end

    def windows
      rpc_send(:vim_get_windows).map do |window|
        window_index = window.data.unpack("c*").first
        Window.new(window_index, self)
      end
    end

    def current_window
      window = rpc_send(:vim_get_current_window)
      window_index = window.data.unpack("c*").first
      Window.new(window_index, self)
    end

    def current_window=(window_index)
      window = Window.new(window_index, self)
      rpc_send(:vim_set_current_window, window)
    end

    def tabpages
      rpc_send(:vim_get_tabpages).map do |tabpage|
        tabpage_index = tabpage.data.unpack("c*").first
        Tabpage.new(tabpage_index, self)
      end
    end

    def current_tabpage
      tabpage = rpc_send(:vim_get_current_tabpage)
      tabpage_index = tabpage.data.unpack("c*").first
      Tabpage.new(tabpage_index, self)
    end

    def current_tabpage=(tabpage_index)
      tabpage = Tabpage.new(tabpage_index, self)
      rpc_send(:vim_set_current_tabpage, tabpage)
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

    private

    def types
      @types ||= @api.fetch("types")
    end
  end
end
