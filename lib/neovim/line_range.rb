module Neovim
  # Provide an enumerable interface for dealing with ranges of lines.
  #
  # @api private
  class LineRange
    include Enumerable

    def initialize(buffer, _begin, _end)
      @buffer = buffer
      @begin = _begin
      @end = _end
    end

    # @return [Array<String>]
    def to_a
      @buffer.get_line_slice(@begin, @end, true, true)
    end

    # @yield [String] The current line
    # @return [Array<String>]
    def each(&block)
      to_a.each(&block)
    end

    # @overload [](index)
    #   @param index [Fixnum]
    #
    # @overload [](range)
    #   @param range [Range]
    #
    # @overload [](index, length)
    #   @param index [Fixnum]
    #   @param length [Fixnum]
    #
    # @example Get the first line using an index
    #   line_range[0] # => "first"
    # @example Get the first two lines using a +Range+
    #   line_range[0..1] # => ["first", "second"]
    # @example Get the first two lines using an index and length
    #   line_range[0, 2] # => ["first", "second"]
    def [](pos, len=nil)
      case pos
      when Range
        LineRange.new(
          @buffer,
          abs_line(pos.begin),
          abs_line(pos.exclude_end? ? pos.end - 1 : pos.end)
        )
      else
        if len
          LineRange.new(
            @buffer,
            abs_line(pos),
            abs_line(pos + len -1)
          )
        else
          @buffer.get_line(abs_line(pos))
        end
      end
    end
    alias_method :slice, :[]

    # @overload []=(index, string)
    #   @param index [Fixnum]
    #   @param string [String]
    #
    # @overload []=(index, length, strings)
    #   @param index [Fixnum]
    #   @param length [Fixnum]
    #   @param strings [Array<String>]
    #
    # @overload []=(range, strings)
    #   @param range [Range]
    #   @param strings [Array<String>]
    #
    # @example Replace the first line using an index
    #   line_range[0] = "first"
    # @example Replace the first two lines using a +Range+
    #   line_range[0..1] = ["first", "second"]
    # @example Replace the first two lines using an index and length
    #   line_range[0, 2] = ["first", "second"]
    def []=(*args)
      *target, val = args
      pos, len = target

      case pos
      when Range
        @buffer.set_line_slice(
          abs_line(pos.begin),
          abs_line(pos.end),
          true,
          !pos.exclude_end?,
          val
        )
      else
        if len
          @buffer.set_line_slice(
            abs_line(pos),
            abs_line(pos + len),
            true,
            false,
            val
          )
        else
          @buffer.set_line(abs_line(pos), val)
        end
      end
    end

    # @param other [Array] The replacement lines
    def replace(other)
      self[0..-1] = other
      self
    end

    # @param index [Fixnum]
    def delete(index)
      @buffer.del_line(abs_line(index))
    end

    private

    def abs_line(n)
      n < 0 ? (@end + n + 1) : @begin + n
    end
  end
end
