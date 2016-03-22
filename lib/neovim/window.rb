require "neovim/object"

module Neovim
  class Window < Neovim::Object
    def cursor
      @cursor ||= Cursor.new(self)
    end

    class Cursor
      def initialize(window)
        @window = window
      end

      def coordinates
        @window.get_cursor
      end

      def coordinates=(coords)
        @window.set_cursor(coords)
      end

      def line
        coordinates[0]
      end

      def line=(n)
        self.coordinates = [n, column]
      end

      def column
        coordinates[1]
      end

      def column=(n)
        self.coordinates = [line, n]
      end

# The following methods are dynamically generated.
=begin
@!method get_buffer
  @return [Buffer]

@!method get_cursor
  @return [Array<Fixnum>]

@!method set_cursor(pos)
  @param [Array<Fixnum>] pos
  @return [void]

@!method get_height
  @return [Fixnum]

@!method set_height(height)
  @param [Fixnum] height
  @return [void]

@!method get_width
  @return [Fixnum]

@!method set_width(width)
  @param [Fixnum] width
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

@!method get_position
  @return [Array<Fixnum>]

@!method get_tabpage
  @return [Tabpage]

@!method is_valid
  @return [Boolean]

=end
    end
  end
end
