module Neovim
  class Buffer
    def initialize(index, client)
      @index = index
      @client = client
    end

    def length
      @client.rpc_response(:buffer_get_length, @index)
    end

    def lines
      Lines.new(@index, @client)
    end
  end

  class Lines
    include Enumerable

    def initialize(buffer_index, client)
      @buffer_index = buffer_index
      @client = client
    end

    def each(&block)
      @client.rpc_response(:buffer_get_slice, @buffer_index, 0, -1, true, true).each do |line|
        yield line
      end
    end

    def []=(index, content)
      if index.is_a?(Range)
        start, finish = index.first, index.last
        @client.rpc_response(:buffer_set_slice, @buffer_index, start, finish, true, true, content)
      else
        start, finish = index, index + 1
        @client.rpc_response(:buffer_set_slice, @buffer_index, start, finish, true, true, [content])
      end
    end
  end
end
