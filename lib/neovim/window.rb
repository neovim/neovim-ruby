module Neovim
  class Window
    attr_reader :index

    def initialize(index, client)
      @index = index
      @client = client
    end

    def buffer
      buffer_index = @client.rpc_response(:window_get_buffer, @index)
      Buffer.new(buffer_index, @client)
    end

    def cursor
      @cursor ||= Cursor.new(@index, @client)
    end

    def cursor=(coords)
      @client.rpc_response(:window_set_cursor, @index, coords)
      @cursor = nil
      coords
    end

    def height
      @height ||= @client.rpc_response(:window_get_height, @index)
    end

    def height=(ht)
      @client.rpc_response(:window_set_height, @index, ht)
      @height = nil
      ht
    end

    def width
      @width ||= @client.rpc_response(:window_get_width, @index)
    end

    def width=(wt)
      @client.rpc_response(:window_set_width, @index, wt)
      @width = nil
      wt
    end

    def variable(name)
      scope = Scope::Window.new(@index)
      Variable.new(name, scope, @client)
    end

    def option(name)
      scope = Scope::Window.new(@index)
      Option.new(name, scope, @client)
    end

    def position
      @client.rpc_response(:window_get_position, @index)
    end

    def valid?
      @client.rpc_response(:window_is_valid, @index)
    end
  end
end
