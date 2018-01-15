require "neovim/ruby_provider/vim"

module Neovim
  # @api private
  class Buffer
    def self.current
      ::Vim.get_current_buf
    end

    def self.count
      ::Vim.list_bufs.size
    end

    def self.[](index)
      ::Vim.list_bufs[index]
    end
  end
end
