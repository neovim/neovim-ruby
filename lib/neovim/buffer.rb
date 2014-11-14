require "neovim/object"
require "neovim/option"
require "neovim/scope"
require "neovim/variable"

module Neovim
  class Buffer < Object
    def length
      @client.rpc_send(:buffer_line_count, to_msgpack)
    end

    def lines
      @lines ||= Lines.new(to_msgpack, @client)
    end

    def lines=(lns)
      lines[0..-1] = lns
    end

    def variable(name)
      scope = Scope::Buffer.new(to_msgpack)
      Variable.new(name, scope, @client)
    end

    def option(name)
      scope = Scope::Buffer.new(to_msgpack)
      Option.new(name, scope, @client)
    end

    def number
      @client.rpc_send(:buffer_get_number, to_msgpack)
    end

    def name
      @client.rpc_send(:buffer_get_name, to_msgpack)
    end

    def name=(name)
      @client.rpc_send(:buffer_set_name, to_msgpack, name)
    end

    def valid?
      @client.rpc_send(:buffer_is_valid, to_msgpack)
    end

    def mark(name)
      @client.rpc_send(:buffer_get_mark, to_msgpack, name)
    end
  end

  class Lines
    include Enumerable

    def initialize(buffer, client)
      @buffer = buffer
      @client = client
    end

    def each(&block)
      @client.rpc_send(:buffer_get_line_slice, @buffer, 0, -1, true, true).each do |line|
        yield line
      end
    end

    def [](index)
      if index.is_a?(Range)
        start, finish = index.first, index.last
        @client.rpc_send(:buffer_get_line_slice, @buffer, start, finish, true, true)
      else
        @client.rpc_send(:buffer_get_line, @buffer, index)
      end
    end

    def []=(index, content)
      if index.is_a?(Range)
        start, finish = index.first, index.last
        @client.rpc_send(:buffer_set_line_slice, @buffer, start, finish, true, true, content)
      else
        @client.rpc_send(:buffer_set_line, @buffer, index, content)
      end
    end

    def delete_at(index)
      line = self[index]
      @client.rpc_send(:buffer_del_line, @buffer, index)
      line
    end
  end
end
