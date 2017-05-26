require "neovim/buffer"
require "neovim/tabpage"
require "neovim/window"

module Neovim
  # Support for +Client#current+ chaining.
  #
  # @see Client#current
  class Current
    def initialize(session)
      @session = session
    end

    # Get the line under the cursor.
    #
    # @return [String]
    def line
      @session.request(:nvim_get_current_line)
    end

    # Set the line under the cursor.
    #
    # @param line [String] The target line contents.
    # @return [String]
    def line=(line)
      @session.request(:nvim_set_current_line, line)
    end

    # Get the active buffer.
    #
    # @return [Buffer]
    def buffer
      @session.request(:nvim_get_current_buf)
    end

    # Set the active buffer.
    #
    # @param buffer [Buffer, Integer] The target buffer or index.
    # @return [Buffer, Integer]
    def buffer=(buffer)
      @session.request(:nvim_set_current_buf, buffer)
    end

    # Get the active window.
    #
    # @return [Window]
    def window
      @session.request(:nvim_get_current_win)
    end

    # Set the active window.
    #
    # @param window [Window, Integer] The target window or index.
    # @return [Window, Integer]
    def window=(window)
      @session.request(:nvim_set_current_win, window)
    end

    # Get the active tabpage.
    #
    # @return [Tabpage]
    def tabpage
      @session.request(:nvim_get_current_tabpage)
    end

    # Set the active tabpage.
    #
    # @param tabpage [Tabpage, Integer] The target tabpage or index.
    # @return [Tabpage, Integer]
    def tabpage=(tabpage)
      @session.request(:nvim_set_current_tabpage, tabpage)
    end
  end
end
