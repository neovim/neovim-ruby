require "neovim/ruby_provider/vim"

module Neovim
  class Buffer
    def self.current
      ::VIM.get_current_buffer
    end

    def self.count
      ::VIM.get_buffers.size
    end

    def self.[](index)
      ::VIM.get_buffers[index]
    end
  end
end
