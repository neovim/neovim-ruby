module Neovim
  class Tabpage
    attr_reader :index

    def initialize(index, client)
      @index = index
      @client = client
    end

    def ==(other)
      @index == other.index
    end

    def windows
      @client.rpc_response(:tabpage_get_windows, @index).map do |window_index|
        Window.new(window_index, @client)
      end
    end

    def current_window
      window_index = @client.rpc_response(:tabpage_get_window, @index)
      Window.new(window_index, @client)
    end

    def variable(name)
      scope = Scope::Tabpage.new(@index)
      Variable.new(name, scope, @client)
    end

    def option(name)
      scope = Scope::Tabpage.new(@index)
      Option.new(name, scope, @client)
    end

    def valid?
      @client.rpc_response(:tabpage_is_valid, @index)
    end
  end
end
