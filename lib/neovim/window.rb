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
  end
end
