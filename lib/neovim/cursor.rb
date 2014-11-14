module Neovim
  class Cursor
    def initialize(window, client)
      @window = window
      @client = client
    end

    def line
      @line ||= @client.rpc_send(:window_get_cursor, @window)[0]
    end

    def line=(ln)
      @client.rpc_send(:window_set_cursor, @window, [ln, column])
      @line = nil
      ln
    end

    def column
      @column ||= @client.rpc_send(:window_get_cursor, @window)[1]
    end

    def column=(col)
      @client.rpc_send(:window_set_cursor, @window, [line, col])
      @column = nil
      col
    end
  end
end
