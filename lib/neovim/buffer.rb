require "neovim/variable"
require "neovim/scope"

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

    def lines=(lines)
      Lines.new(@index, @client)[0..-1] = lines
    end

    def variable(name)
      scope = Scope::Buffer.new(@index)
      Variable.new(name, scope, @client)
    end

    def option(name)
      scope = Scope::Buffer.new(@index)
      Option.new(name, scope, @client)
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

    def [](index)
      if index.is_a?(Range)
        start, finish = index.first, index.last
        @client.rpc_response(:buffer_get_slice, @buffer_index, start, finish, true, true)
      else
        @client.rpc_response(:buffer_get_line, @buffer_index, index)
      end
    end

    def []=(index, content)
      if index.is_a?(Range)
        start, finish = index.first, index.last
        @client.rpc_response(:buffer_set_slice, @buffer_index, start, finish, true, true, content)
      else
        @client.rpc_response(:buffer_set_line, @buffer_index, index, content)
      end
    end

    def delete_at(index)
      line = self[index]
      @client.rpc_response(:buffer_del_line, @buffer_index, index)
      line
    end
  end
end
