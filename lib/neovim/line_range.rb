module Neovim
  class LineRange
    include Enumerable

    def initialize(buffer, _begin, _end)
      @buffer = buffer
      @begin = _begin
      @end = _end
    end

    def to_a
      @buffer.get_line_slice(@begin, @end, true, true)
    end

    def each(&block)
      to_a.each(&block)
    end

    def [](idx, len=nil)
      case idx
      when ::Range
        _end = idx.exclude_end? ? idx.end - 1 : idx.end
        LineRange.new(@buffer, idx.begin, _end)
      else
        if len
          LineRange.new(@buffer, idx, idx + len - 1)
        else
          @buffer.get_line(idx)
        end
      end
    end
    alias_method :slice, :[]

    def []=(*args)
      *target, val = args
      idx, len = target

      case idx
      when ::Range
        @buffer.set_line_slice(
          idx.begin,
          idx.end,
          true,
          !idx.exclude_end?,
          val
        )
      else
        if len
          @buffer.set_line_slice(idx, idx + len, true, false, val)
        else
          @buffer.set_line(idx, val)
        end
      end
    end

    def replace(other_ary)
      self[0..-1] = other_ary
      self
    end
  end
end
