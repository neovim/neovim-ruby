require "neovim/buffer"
require "neovim/cursor"
require "neovim/option"
require "neovim/scope"
require "neovim/tabpage"
require "neovim/variable"

module Neovim
  class Window < Object
    def ==(other)
      @index == other.index
    end

    def buffer
      @client.rpc_send(:window_get_buffer, self)
    end

    def cursor
      @cursor ||= Cursor.new(self, @client)
    end

    def cursor=(coords)
      @client.rpc_send(:window_set_cursor, self, coords)
      @cursor = nil
      coords
    end

    def height
      @height ||= @client.rpc_send(:window_get_height, self)
    end

    def height=(ht)
      @client.rpc_send(:window_set_height, self, ht)
      @height = nil
      ht
    end

    def width
      @width ||= @client.rpc_send(:window_get_width, self)
    end

    def width=(wt)
      @client.rpc_send(:window_set_width, self, wt)
      @width = nil
      wt
    end

    def variable(name)
      scope = Scope::Window.new(self)
      Variable.new(name, scope, @client)
    end

    def option(name)
      scope = Scope::Window.new(self)
      Option.new(name, scope, @client)
    end

    def position
      @client.rpc_send(:window_get_position, self)
    end

    def tabpage
      @client.rpc_send(:window_get_tabpage, self)
    end

    def valid?
      @client.rpc_send(:window_is_valid, self)
    end
  end
end
