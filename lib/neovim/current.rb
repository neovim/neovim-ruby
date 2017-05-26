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
      @session.request(:vim_get_current_line)
    end

    # Set the line under the cursor.
    #
    # @param line [String] The target line contents.
    # @return [String]
    def line=(line)
      @session.request(:vim_set_current_line, line)
    end

    # Get the active buffer.
    #
    # @return [Buffer]
    def buffer
      @session.request(:vim_get_current_buffer)
    end

    # Set the active buffer.
    #
    # @param buffer [Buffer, Integer] The target buffer or index.
    # @return [Buffer, Integer]
    def buffer=(buffer)
      @session.request(:vim_set_current_buffer, buffer)
    end

    # Get the active window.
    #
    # @return [Window]
    def window
      @session.request(:vim_get_current_window)
    end

    # Set the active window.
    #
    # @param window [Window, Integer] The target window or index.
    # @return [Window, Integer]
    def window=(window)
      @session.request(:vim_set_current_window, window)
    end

    # Get the active tabpage.
    #
    # @return [Tabpage]
    def tabpage
      @session.request(:vim_get_current_tabpage)
    end

    # Set the active tabpage.
    #
    # @param tabpage [Tabpage, Integer] The target tabpage or index.
    # @return [Tabpage, Integer]
    def tabpage=(tabpage)
      @session.request(:vim_set_current_tabpage, tabpage)
    end
  end
end
