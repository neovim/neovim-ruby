require "neovim/option"
require "neovim/scope"
require "neovim/variable"
require "neovim/window"

module Neovim
  class Tabpage < Object
    def ==(other)
      @index == other.index
    end

    def windows
      @client.rpc_send(:tabpage_get_windows, self)
    end

    def current_window
      @client.rpc_send(:tabpage_get_window, self)
    end

    def variable(name)
      scope = Scope::Tabpage.new(self)
      Variable.new(name, scope, @client)
    end

    def option(name)
      scope = Scope::Tabpage.new(self)
      Option.new(name, scope, @client)
    end

    def valid?
      @client.rpc_send(:tabpage_is_valid, self)
    end
  end
end
