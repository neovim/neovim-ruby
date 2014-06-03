module Neovim
  Cursor = Struct.new(:line, :column)

  class Window
    def initialize(index, client)
      @index = index
      @client = client
    end

    def buffer
      buffer_index = @client.rpc_response(:window_get_buffer, @index)
      Buffer.new(buffer_index, @client)
    end

    def cursor
      line, col = @client.rpc_response(:window_get_cursor, @index)
      Cursor.new(line, col)
    end
  end
end
