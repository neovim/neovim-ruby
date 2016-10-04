require "neovim/ruby_provider/vim"

module Neovim
  class Window
    def self.current
      ::Vim.get_current_window
    end

    def self.count
      ::Vim.get_current_tabpage.get_windows.size
    end

    def self.[](index)
      ::Vim.get_current_tabpage.get_windows[index]
    end
  end
end
