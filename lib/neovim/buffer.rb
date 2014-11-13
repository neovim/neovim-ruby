require "neovim/option"
require "neovim/scope"
require "neovim/variable"

module Neovim
  class Buffer
    attr_reader :index

    def initialize(index, client)
      @index = [index].pack("c*")
      @client = client
    end

    def to_ext
      MessagePack::Extended.create(0, @index)
    end

    def length
      @client.rpc_send(:buffer_line_count, to_ext)
    end

    def lines
      @lines ||= Lines.new(@index, @client)
    end

    def lines=(lns)
      lines[0..-1] = lns
    end

    def variable(name)
      scope = Scope::Buffer.new(@index)
      Variable.new(name, scope, @client)
    end

    def option(name)
      scope = Scope::Buffer.new(@index)
      Option.new(name, scope, @client)
    end

    def number
      @client.rpc_send(:buffer_get_number, to_ext)
    end

    def name
      @client.rpc_send(:buffer_get_name, to_ext)
    end

    def name=(name)
      @client.rpc_send(:buffer_set_name, to_ext, name)
    end

    def valid?
      @client.rpc_send(:buffer_is_valid, to_ext)
    end

    def mark(name)
      @client.rpc_send(:buffer_get_mark, to_ext, name)
    end
  end

  class Lines
    include Enumerable

    def initialize(buffer_index, client)
      @buffer_index = buffer_index
      @client = client
    end

    def each(&block)
      @client.rpc_send(:buffer_get_line_slice, @buffer_index, 0, -1, true, true).each do |line|
        yield line
      end
    end

    def [](index)
      if index.is_a?(Range)
        start, finish = index.first, index.last
        @client.rpc_send(:buffer_get_line_slice, @buffer_index, start, finish, true, true)
      else
        @client.rpc_send(:buffer_get_line, @buffer_index, index)
      end
    end

    def []=(index, content)
      if index.is_a?(Range)
        start, finish = index.first, index.last
        @client.rpc_send(:buffer_set_line_slice, @buffer_index, start, finish, true, true, content)
      else
        @client.rpc_send(:buffer_set_line, @buffer_index, index, content)
      end
    end

    def delete_at(index)
      line = self[index]
      @client.rpc_send(:buffer_del_line, @buffer_index, index)
      line
    end
  end
end
