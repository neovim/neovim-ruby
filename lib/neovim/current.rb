require "neovim/buffer"
require "neovim/tabpage"
require "neovim/window"

module Neovim
  # Support for +client.current+ chaining.
  # @see Client#current
  class Current
    def initialize(session)
      @session = session
    end

    # @return [String]
    def line
      @session.request(:vim_get_current_line)
    end

    # @param line [String] The target line contents.
    # @return [String]
    def line=(line)
      @session.request(:vim_set_current_line, line)
    end

    # @return [Buffer]
    def buffer
      @session.request(:vim_get_current_buffer)
    end

    # @param buffer [Buffer, Fixnum] The target buffer or index.
    # @return [Buffer, Fixnum]
    def buffer=(buffer)
      @session.request(:vim_set_current_buffer, buffer)
    end

    # @return [Window]
    def window
      @session.request(:vim_get_current_window)
    end

    # @param window [Window, Fixnum] The target window or index.
    # @return [Window, Fixnum]
    def window=(window)
      @session.request(:vim_set_current_window, window)
    end

    # @return [Tabpage]
    def tabpage
      @session.request(:vim_get_current_tabpage)
    end

    # @param tabpage [Tabpage, Fixnum] The target tabpage or index.
    # @return [Tabpage, Fixnum]
    def tabpage=(tabpage)
      @session.request(:vim_set_current_tabpage, tabpage)
    end
  end
end
