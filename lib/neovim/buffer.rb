require "neovim/remote_object"
require "neovim/line_range"

module Neovim
  # Class representing an +nvim+ buffer.
  #
  # The methods documented here were generated using NVIM v0.2.2
  class Buffer < RemoteObject
    attr_reader :lines

    def initialize(*args)
      super
      @lines = LineRange.new(self)
    end

    # Replace all the lines of the buffer.
    #
    # @param strs [Array<String>] The replacement lines
    # @return [Array<String>]
    def lines=(strs)
      @lines[0..-1] = strs
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
      check_index(index)
      @lines[index - 1]
    end

    # Set the given line (1-indexed).
    #
    # @param index [Integer]
    # @param str [String]
    # @return [String]
    def []=(index, str)
      check_index(index)
      @lines[index - 1] = str
    end

    # Delete the given line (1-indexed).
    #
    # @param index [Integer]
    # @return [void]
    def delete(index)
      check_index(index)
      @lines.delete(index - 1)
      nil
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
      check_index(index)
      window = @session.request(:nvim_get_current_win)
      cursor = window.cursor

      set_lines(index, index, true, [str])
      window.set_cursor(cursor)
      str
    end

    # Get the current line of an active buffer.
    #
    # @return [String, nil]
    def line
      @session.request(:nvim_get_current_line) if active?
    end

    # Set the current line of an active buffer.
    #
    # @param str [String]
    # @return [String, nil]
    def line=(str)
      @session.request(:nvim_set_current_line, str) if active?
    end

    # Get the current line number of an active buffer.
    #
    # @return [Integer, nil]
    def line_number
      @session.request(:nvim_get_current_win).get_cursor[0] if active?
    end

    # Determine if the buffer is active.
    #
    # @return [Boolean]
    def active?
      @session.request(:nvim_get_current_buf) == self
    end

    private

    def check_index(index)
      raise ArgumentError, "Index out of bounds" if index < 0
    end

    public

# The following methods are dynamically generated.
=begin
@method line_count(buffer)
  See +:h nvim_buf_line_count()+
  @param [Buffer] buffer
  @return [Integer]

@method get_lines(buffer, start, end, strict_indexing)
  See +:h nvim_buf_get_lines()+
  @param [Buffer] buffer
  @param [Integer] start
  @param [Integer] end
  @param [Boolean] strict_indexing
  @return [Array<String>]

@method set_lines(buffer, start, end, strict_indexing, replacement)
  See +:h nvim_buf_set_lines()+
  @param [Buffer] buffer
  @param [Integer] start
  @param [Integer] end
  @param [Boolean] strict_indexing
  @param [Array<String>] replacement
  @return [void]

@method get_var(buffer, name)
  See +:h nvim_buf_get_var()+
  @param [Buffer] buffer
  @param [String] name
  @return [Object]

@method get_changedtick(buffer)
  See +:h nvim_buf_get_changedtick()+
  @param [Buffer] buffer
  @return [Integer]

@method get_keymap(buffer, mode)
  See +:h nvim_buf_get_keymap()+
  @param [Buffer] buffer
  @param [String] mode
  @return [Array<Hash>]

@method set_var(buffer, name, value)
  See +:h nvim_buf_set_var()+
  @param [Buffer] buffer
  @param [String] name
  @param [Object] value
  @return [void]

@method del_var(buffer, name)
  See +:h nvim_buf_del_var()+
  @param [Buffer] buffer
  @param [String] name
  @return [void]

@method get_option(buffer, name)
  See +:h nvim_buf_get_option()+
  @param [Buffer] buffer
  @param [String] name
  @return [Object]

@method set_option(buffer, name, value)
  See +:h nvim_buf_set_option()+
  @param [Buffer] buffer
  @param [String] name
  @param [Object] value
  @return [void]

@method get_number(buffer)
  See +:h nvim_buf_get_number()+
  @param [Buffer] buffer
  @return [Integer]

@method get_name(buffer)
  See +:h nvim_buf_get_name()+
  @param [Buffer] buffer
  @return [String]

@method set_name(buffer, name)
  See +:h nvim_buf_set_name()+
  @param [Buffer] buffer
  @param [String] name
  @return [void]

@method is_valid(buffer)
  See +:h nvim_buf_is_valid()+
  @param [Buffer] buffer
  @return [Boolean]

@method get_mark(buffer, name)
  See +:h nvim_buf_get_mark()+
  @param [Buffer] buffer
  @param [String] name
  @return [Array<Integer>]

@method add_highlight(buffer, src_id, hl_group, line, col_start, col_end)
  See +:h nvim_buf_add_highlight()+
  @param [Buffer] buffer
  @param [Integer] src_id
  @param [String] hl_group
  @param [Integer] line
  @param [Integer] col_start
  @param [Integer] col_end
  @return [Integer]

@method clear_highlight(buffer, src_id, line_start, line_end)
  See +:h nvim_buf_clear_highlight()+
  @param [Buffer] buffer
  @param [Integer] src_id
  @param [Integer] line_start
  @param [Integer] line_end
  @return [void]

=end
  end
end
