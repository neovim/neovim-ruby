require "neovim/option"
require "neovim/scope"
require "neovim/variable"
require "neovim/window"

module Neovim
  class Tabpage
    attr_reader :index

    def initialize(index, client)
      @index  = index
      @client = client
      @handle = [index].pack("c*")
    end

    def to_ext
      @to_ext ||= MessagePack::Extended.create(2, @handle)
    end

    def ==(other)
      @index == other.index
    end

    def windows
      @client.rpc_send(:tabpage_get_windows, to_ext).map do |window|
        window_index = window.data.unpack("c*").first
        Window.new(window_index, @client)
      end
    end

    def current_window
      window = @client.rpc_send(:tabpage_get_window, to_ext)
      window_index = window.data.unpack("c*").first
      Window.new(window_index, @client)
    end

    def variable(name)
      scope = Scope::Tabpage.new(to_ext)
      Variable.new(name, scope, @client)
    end

    def option(name)
      scope = Scope::Tabpage.new(to_ext)
      Option.new(name, scope, @client)
    end

    def valid?
      @client.rpc_send(:tabpage_is_valid, to_ext)
    end
  end
end
