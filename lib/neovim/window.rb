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
      Cursor.new(@index, @client)
    end
  end
end
