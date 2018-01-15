module Neovim
  # Provide an enumerable interface for dealing with ranges of lines.
  class LineRange
    include Enumerable

    def initialize(buffer)
      @buffer = buffer
    end

    # Satisfy the +Enumerable+ interface by yielding each line.
    #
    # @yieldparam line [String]
    def each(&block)
      (0...@buffer.count).each_slice(5000) do |linenos|
        start, stop = linenos[0], linenos[-1] + 1
        @buffer.get_lines(start, stop, true).each(&block)
      end
    end

    # Resolve to an array of lines as strings.
    #
    # @return [Array<String>]
    def to_a
      map { |line| line }
    end

    # Override +#==+ to compare contents of lines.
    #
    # @return Boolean
    def ==(other)
      to_a == other.to_a
    end

    # Access a line or line range.
    #
    # @overload [](index)
    #   @param index [Integer]
    #
    # @overload [](range)
    #   @param range [Range]
    #
    # @overload [](index, length)
    #   @param index [Integer]
    #   @param length [Integer]
    #
    # @example Get the first line using an index
    #   line_range[0] # => "first"
    # @example Get the first two lines using a +Range+
    #   line_range[0..1] # => ["first", "second"]
    # @example Get the first two lines using an index and length
    #   line_range[0, 2] # => ["first", "second"]
    def [](pos, len=nil)
      if pos.is_a?(Range)
        @buffer.get_lines(*range_indices(pos), true)
      else
        start, stop = length_indices(pos, len || 1)
        lines = @buffer.get_lines(start, stop, true)
        len ? lines : lines.first
      end
    end
    alias slice []

    # Set a line or line range.
    #
    # @overload []=(index, string)
    #   @param index [Integer]
    #   @param string [String]
    #
    # @overload []=(index, length, strings)
    #   @param index [Integer]
    #   @param length [Integer]
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

      if pos.is_a?(Range)
        @buffer.set_lines(*range_indices(pos), true, Array(val))
      else
        start, stop = length_indices(pos, len || 1)
        @buffer.set_lines(start, stop, true, Array(val))
      end
    end

    # Replace the range of lines.
    #
    # @param other [Array] The replacement lines
    def replace(other)
      self[0..-1] = other.to_ary
      self
    end

    # Delete the line at the given index within the range.
    #
    # @param index [Integer]
    def delete(index)
      i = Integer(index)
      self[i].tap { self[i, 1] = [] }
    rescue TypeError
    end

    private

    def range_indices(range)
      start = adjust_index(range.begin)
      stop = adjust_index(range.end)
      stop += 1 unless range.exclude_end?

      [start, stop]
    end

    def length_indices(index, len)
      start = adjust_index(index)
      stop = start < 0 ? [start + len, -1].min : start + len

      [start, stop]
    end

    def adjust_index(i)
      i < 0 ? i - 1 : i
    end
  end
end
