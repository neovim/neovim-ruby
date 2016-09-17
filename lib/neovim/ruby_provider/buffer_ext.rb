require "neovim/ruby_provider/vim"

module Neovim
  class Buffer
    def self.current
      ::Vim.get_current_buffer
    end

    def self.count
      ::Vim.get_buffers.size
    end

    def self.[](index)
      ::Vim.get_buffers[index]
    end
  end
end
