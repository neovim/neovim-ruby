require "neovim/buffer"
require "neovim/tabpage"
require "neovim/window"

module Neovim
  class Current
    def initialize(client)
      @client = client
    end

    def line
      @client.rpc_send(:vim_get_current_line)
    end

    def line=(ln)
      @client.rpc_send(:vim_set_current_line, ln)
    end

    def buffer
      @client.rpc_send(:vim_get_current_buffer)
    end

    def buffer=(buffer_index)
      buffer = Buffer.new(buffer_index, @client)
      @client.rpc_send(:vim_set_current_buffer, buffer)
    end

    def window
      @client.rpc_send(:vim_get_current_window)
    end

    def window=(window_index)
      window = Window.new(window_index, @client)
      @client.rpc_send(:vim_set_current_window, window)
    end

    def tabpage
      @client.rpc_send(:vim_get_current_tabpage)
    end

    def tabpage=(tabpage_index)
      tabpage = Tabpage.new(tabpage_index, @client)
      @client.rpc_send(:vim_set_current_tabpage, tabpage)
    end
  end
end
