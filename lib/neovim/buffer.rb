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

    def range
      @range ||= LineRange.new(self, 0, -1)
    end

    def range=(_range)
      _end = _range.exclude_end? ? _range.end - 1 : _range.end
      @range = LineRange.new(self, _range.begin, _end)
    end
  end
end
