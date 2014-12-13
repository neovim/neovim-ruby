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
      @rpc = RPC.new(io, self)
    end

    def message(msg)
      rpc_send(:vim_out_write, msg)
    end

    def error(msg)
      rpc_send(:vim_err_write, msg)
    end

    def report_error(msg)
      rpc_send(:vim_report_error, msg)
    end

    def command(cmd)
      rpc_send(:vim_command, cmd)
      self
    end

    def command_output(cmd)
      rpc_send(:vim_command_output, cmd)
    end

    def evaluate(expr)
      rpc_send(:vim_eval, expr)
    end

    def feed_keys(keys, mode, escape_csi)
      rpc_send(:vim_feedkeys, keys, mode, escape_csi)
      self
    end

    def input(keys)
      rpc_send(:vim_input, keys)
    end

    def strwidth(str)
      rpc_send(:vim_strwidth, str)
    end

    def replace_termcodes(str, from_part, do_lt, special)
      rpc_send(:vim_replace_termcodes, str, from_part, do_lt, special)
    end

    def name_to_color(name)
      rpc_send(:vim_name_to_color, name)
    end

    def runtime_paths
      rpc_send(:vim_list_runtime_paths)
    end

    def change_directory(dir)
      rpc_send(:vim_change_directory, dir)
      self
    end

    def buffers
      rpc_send(:vim_get_buffers)
    end

    def current
      Current.new(self)
    end

    def delete_current_line
      rpc_send(:vim_del_current_line)
    end

    def windows
      rpc_send(:vim_get_windows)
    end

    def tabpages
      rpc_send(:vim_get_tabpages)
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

    def class_for(type_code)
      types.inject(nil) do |klass, (class_str, data)|
        next(klass) if klass

        if data["id"] == type_code
          Neovim.const_get(class_str)
        end
      end
    end

    def type_code_for(klass)
      unqualified = klass.to_s.split("::").last
      types.fetch(unqualified).fetch("id")
    end

    private

    def types
      @types ||= begin
        rpc_send(:vim_get_api_info).fetch(1).fetch("types")
      end
    end
  end
end
