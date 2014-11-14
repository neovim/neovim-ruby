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
      @client.rpc_send(:tabpage_get_windows, to_msgpack).map do |window|
        window_index = window.data.unpack("c*").first
        Window.new(window_index, @client)
      end
    end

    def current_window
      window = @client.rpc_send(:tabpage_get_window, to_msgpack)
      window_index = window.data.unpack("c*").first
      Window.new(window_index, @client)
    end

    def variable(name)
      scope = Scope::Tabpage.new(to_msgpack)
      Variable.new(name, scope, @client)
    end

    def option(name)
      scope = Scope::Tabpage.new(to_msgpack)
      Option.new(name, scope, @client)
    end

    def valid?
      @client.rpc_send(:tabpage_is_valid, to_msgpack)
    end
  end
end
