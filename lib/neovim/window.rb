require "neovim/buffer"
require "neovim/cursor"
require "neovim/option"
require "neovim/scope"
require "neovim/tabpage"
require "neovim/variable"

module Neovim
  class Window
    attr_reader :index

    def initialize(index, client)
      @index  = index
      @client = client
      @handle = [index].pack("c*")
    end

    def to_ext
      @to_ext ||= MessagePack::Extended.create(1, @handle)
    end

    def ==(other)
      @index == other.index
    end

    def buffer
      buffer = @client.rpc_send(:window_get_buffer, to_ext)
      buffer_index = buffer.data.unpack("c*").first
      Buffer.new(buffer_index, @client)
    end

    def cursor
      @cursor ||= Cursor.new(to_ext, @client)
    end

    def cursor=(coords)
      @client.rpc_send(:window_set_cursor, to_ext, coords)
      @cursor = nil
      coords
    end

    def height
      @height ||= @client.rpc_send(:window_get_height, to_ext)
    end

    def height=(ht)
      @client.rpc_send(:window_set_height, to_ext, ht)
      @height = nil
      ht
    end

    def width
      @width ||= @client.rpc_send(:window_get_width, to_ext)
    end

    def width=(wt)
      @client.rpc_send(:window_set_width, to_ext, wt)
      @width = nil
      wt
    end

    def variable(name)
      scope = Scope::Window.new(to_ext)
      Variable.new(name, scope, @client)
    end

    def option(name)
      scope = Scope::Window.new(to_ext)
      Option.new(name, scope, @client)
    end

    def position
      @client.rpc_send(:window_get_position, to_ext)
    end

    def tabpage
      tabpage = @client.rpc_send(:window_get_tabpage, to_ext)
      tabpage_index = tabpage.data.unpack("c*").first
      Tabpage.new(tabpage_index, @client)
    end

    def valid?
      @client.rpc_send(:window_is_valid, to_ext)
    end
  end
end
