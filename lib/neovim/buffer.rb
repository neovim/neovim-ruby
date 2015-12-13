require "neovim/object"
require "neovim/line_range"

module Neovim
  class Buffer < Neovim::Object
    def lines
      @lines ||= LineRange.new(self, 0, -1)
    end

    def lines=(arr)
      lines[0..-1] = arr
    end
  end
end
