require "neovim/ruby_provider/vim"

module Neovim
  # @api private
  class Window
    def self.current
      ::Vim.get_current_win
    end

    def self.count
      ::Vim.get_current_tabpage.list_wins.size
    end

    def self.[](index)
      ::Vim.get_current_tabpage.list_wins[index]
    end
  end
end
