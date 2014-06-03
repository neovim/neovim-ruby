module Neovim
  class Cursor
    def initialize(window_index, client)
      @window_index = window_index
      @client = client
    end

    def line
      @line ||= @client.rpc_response(:window_get_cursor, @window_index)[0]
    end

    def line=(ln)
      @client.rpc_response(:window_set_cursor, @window_index, [ln, column])
      @line = nil
      ln
    end

    def column
      @column ||= @client.rpc_response(:window_get_cursor, @window_index)[1]
    end

    def column=(col)
      @client.rpc_response(:window_set_cursor, @window_index, [line, col])
      @column = nil
      col
    end
  end
end
