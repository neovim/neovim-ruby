module Neovim
  class Current
    def initialize(rpc)
      @rpc = rpc
    end

    def line
      @rpc.send(:vim_get_current_line)
    end

    def line=(ln)
      @rpc.send(:vim_set_current_line, ln)
    end

    def buffer
      @rpc.send(:vim_get_current_buffer)
    end

    def buffer=(buffer_index)
      buffer = Buffer.new(buffer_index, @rpc)
      @rpc.send(:vim_set_current_buffer, buffer)
    end

    def window
      @rpc.send(:vim_get_current_window)
    end

    def window=(window_index)
      window = Window.new(window_index, @rpc)
      @rpc.send(:vim_set_current_window, window)
    end

    def tabpage
      @rpc.send(:vim_get_current_tabpage)
    end

    def tabpage=(tabpage_index)
      tabpage = Tabpage.new(tabpage_index, @rpc)
      @rpc.send(:vim_set_current_tabpage, tabpage)
    end
  end
end
