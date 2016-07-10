require "neovim/ruby_provider/vim"

module Neovim
  class Window
    def self.current
      ::VIM.get_current_window
    end

    def self.count
      ::VIM.get_windows.size
    end

    def self.[](index)
      ::VIM.get_windows[index]
    end
  end
end
