require "neovim/object"

module Neovim
  class Current
    def initialize(session)
      @session = session
    end

    def line
      @session.request(:vim_get_current_line)
    end

    def line=(ln)
      @session.request(:vim_set_current_line, ln)
    end

    def buffer
      @session.request(:vim_get_current_buffer)
    end

    def buffer=(buffer_index)
      buffer = Buffer.new(buffer_index, @session)
      @session.request(:vim_set_current_buffer, buffer)
    end

    def window
      @session.request(:vim_get_current_window)
    end

    def window=(window_index)
      window = Window.new(window_index, @session)
      @session.request(:vim_set_current_window, window)
    end

    def tabpage
      @session.request(:vim_get_current_tabpage)
    end

    def tabpage=(tabpage_index)
      tabpage = Tabpage.new(tabpage_index, @session)
      @session.request(:vim_set_current_tabpage, tabpage)
    end
  end
end
