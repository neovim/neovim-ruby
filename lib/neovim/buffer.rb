require "neovim/remote_object"
require "neovim/line_range"

module Neovim
  # Class representing an +nvim+ buffer.
  #
  # The methods documented here were generated using NVIM v0.2.0
  class Buffer < RemoteObject
    # A +LineRange+ object representing the buffer's lines.
    #
    # @return [LineRange]
    # @see LineRange
    def lines
      @lines ||= LineRange.new(self, 0, -1)
    end

    # Replace all the lines of the buffer.
    #
    # @param strs [Array<String>] The replacement lines
    # @return [Array<String>]
    def lines=(strs)
      lines[0..-1] = strs
    end

    # A +LineRange+ object representing the buffer's selection range.
    #
    # @return [LineRange]
    # @see LineRange
    def range
      @range ||= LineRange.new(self, 0, -1)
    end

    # Set the buffer's current selection range.
    #
    # @param _range [Range] The replacement range
    # @return [LineRange]
    # @see LineRange
    def range=(_range)
      _end = _range.exclude_end? ? _range.end - 1 : _range.end
      @range = LineRange.new(self, _range.begin, _end)
    end

    # Get the buffer name.
    #
    # @return [String]
    def name
      get_name
    end

    # Get the buffer index.
    #
    # @return [Integer]
    def number
      get_number
    end

    # Get the number of lines.
    #
    # @return [Integer]
    def count
      line_count
    end

    # Get the number of lines.
    #
    # @return [Integer]
    def length
      count
    end

    # Get the given line (1-indexed).
    #
    # @param index [Integer]
    # @return [String]
    def [](index)
      lines[index-1]
    end

    # Set the given line (1-indexed).
    #
    # @param index [Integer]
    # @param str [String]
    # @return [String]
    def []=(index, str)
      lines[index-1] = str
    end

    # Delete the given line (1-indexed).
    #
    # @param index [Integer]
    # @return [void]
    def delete(index)
      lines.delete(index-1)
    end

    # Append a line after the given line (1-indexed).
    #
    # To maintain backwards compatibility with +vim+, the cursor is forced back
    # to its previous position after inserting the line.
    #
    # @param index [Integer]
    # @param str [String]
    # @return [String]
    def append(index, str)
      window = @session.request(:vim_get_current_window)
      cursor = window.cursor

      if index < 0
        raise ArgumentError, "Index out of bounds"
      else
        set_lines(index, index, true, [str])
        window.set_cursor(cursor)
      end
      str
    end

    # Get the current line of an active buffer.
    #
    # @return [String, nil]
    def line
      if active?
        @session.request(:vim_get_current_line)
      end
    end

    # Set the current line of an active buffer.
    #
    # @param str [String]
    # @return [String, nil]
    def line=(str)
      if active?
        @session.request(:vim_set_current_line, str)
      end
    end

    # Get the current line number of an active buffer.
    #
    # @return [Integer, nil]
    def line_number
      if active?
        window = @session.request(:vim_get_current_window)
        @session.request(:window_get_cursor, window)[0]
      end
    end

    # Determine if the buffer is active.
    #
    # @return [Boolean]
    def active?
      @session.request(:vim_get_current_buffer) == self
    end

# The following methods are dynamically generated.
=begin
@method get_line(index)
  Send the +buffer_get_line+ RPC to +nvim+
  @param [Integer] index
  @return [String]

@method set_line(index, line)
  Send the +buffer_set_line+ RPC to +nvim+
  @param [Integer] index
  @param [String] line
  @return [void]

@method del_line(index)
  Send the +buffer_del_line+ RPC to +nvim+
  @param [Integer] index
  @return [void]

@method get_line_slice(start, end, include_start, include_end)
  Send the +buffer_get_line_slice+ RPC to +nvim+
  @param [Integer] start
  @param [Integer] end
  @param [Boolean] include_start
  @param [Boolean] include_end
  @return [Array<String>]

@method set_line_slice(start, end, include_start, include_end, replacement)
  Send the +buffer_set_line_slice+ RPC to +nvim+
  @param [Integer] start
  @param [Integer] end
  @param [Boolean] include_start
  @param [Boolean] include_end
  @param [Array<String>] replacement
  @return [void]

@method set_var(name, value)
  Send the +buffer_set_var+ RPC to +nvim+
  @param [String] name
  @param [Object] value
  @return [Object]

@method del_var(name)
  Send the +buffer_del_var+ RPC to +nvim+
  @param [String] name
  @return [Object]

@method insert(lnum, lines)
  Send the +buffer_insert+ RPC to +nvim+
  @param [Integer] lnum
  @param [Array<String>] lines
  @return [void]

@method line_count
  Send the +buffer_line_count+ RPC to +nvim+
  @return [Integer]

@method get_lines(start, end, strict_indexing)
  Send the +buffer_get_lines+ RPC to +nvim+
  @param [Integer] start
  @param [Integer] end
  @param [Boolean] strict_indexing
  @return [Array<String>]

@method set_lines(start, end, strict_indexing, replacement)
  Send the +buffer_set_lines+ RPC to +nvim+
  @param [Integer] start
  @param [Integer] end
  @param [Boolean] strict_indexing
  @param [Array<String>] replacement
  @return [void]

@method get_var(name)
  Send the +buffer_get_var+ RPC to +nvim+
  @param [String] name
  @return [Object]

@method get_option(name)
  Send the +buffer_get_option+ RPC to +nvim+
  @param [String] name
  @return [Object]

@method set_option(name, value)
  Send the +buffer_set_option+ RPC to +nvim+
  @param [String] name
  @param [Object] value
  @return [void]

@method get_number
  Send the +buffer_get_number+ RPC to +nvim+
  @return [Integer]

@method get_name
  Send the +buffer_get_name+ RPC to +nvim+
  @return [String]

@method set_name(name)
  Send the +buffer_set_name+ RPC to +nvim+
  @param [String] name
  @return [void]

@method is_valid
  Send the +buffer_is_valid+ RPC to +nvim+
  @return [Boolean]

@method get_mark(name)
  Send the +buffer_get_mark+ RPC to +nvim+
  @param [String] name
  @return [Array<Integer>]

@method add_highlight(src_id, hl_group, line, col_start, col_end)
  Send the +buffer_add_highlight+ RPC to +nvim+
  @param [Integer] src_id
  @param [String] hl_group
  @param [Integer] line
  @param [Integer] col_start
  @param [Integer] col_end
  @return [Integer]

@method clear_highlight(src_id, line_start, line_end)
  Send the +buffer_clear_highlight+ RPC to +nvim+
  @param [Integer] src_id
  @param [Integer] line_start
  @param [Integer] line_end
  @return [void]

=end
  end
end
