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

# The following methods are dynamically generated.
=begin
@!method line_count
  @return [Fixnum]

@!method get_line(index)
  @param [Fixnum] index
  @return [String]

@!method set_line(index, line)
  @param [Fixnum] index
  @param [String] line
  @return [void]

@!method del_line(index)
  @param [Fixnum] index
  @return [void]

@!method get_line_slice(start, end, include_start, include_end)
  @param [Fixnum] start
  @param [Fixnum] end
  @param [Boolean] include_start
  @param [Boolean] include_end
  @return [Array<String>]

@!method set_line_slice(start, end, include_start, include_end, replacement)
  @param [Fixnum] start
  @param [Fixnum] end
  @param [Boolean] include_start
  @param [Boolean] include_end
  @param [Array<String>] replacement
  @return [void]

@!method get_var(name)
  @param [String] name
  @return [Object]

@!method set_var(name, value)
  @param [String] name
  @param [Object] value
  @return [Object]

@!method get_option(name)
  @param [String] name
  @return [Object]

@!method set_option(name, value)
  @param [String] name
  @param [Object] value
  @return [void]

@!method get_number
  @return [Fixnum]

@!method get_name
  @return [String]

@!method set_name(name)
  @param [String] name
  @return [void]

@!method is_valid
  @return [Boolean]

@!method insert(lnum, lines)
  @param [Fixnum] lnum
  @param [Array<String>] lines
  @return [void]

@!method get_mark(name)
  @param [String] name
  @return [Array<Fixnum>]

@!method add_highlight(src_id, hl_group, line, col_start, col_end)
  @param [Fixnum] src_id
  @param [String] hl_group
  @param [Fixnum] line
  @param [Fixnum] col_start
  @param [Fixnum] col_end
  @return [Fixnum]

@!method clear_highlight(src_id, line_start, line_end)
  @param [Fixnum] src_id
  @param [Fixnum] line_start
  @param [Fixnum] line_end
  @return [void]

=end
  end
end
