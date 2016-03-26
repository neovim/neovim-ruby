require "neovim/remote_object"

module Neovim
  class Window < RemoteObject
    # Interface for interacting with the cursor position.
    #
    # @return [Cursor]
    # @see Cursor
    def cursor
      @cursor ||= Cursor.new(self)
    end

    class Cursor
      def initialize(window)
        @window = window
      end

      # Get the current coordinates of the cursor.
      #
      # @return [Array<Fixnum>]
      # @note coordinates are 1-indexed
      def coordinates
        @window.get_cursor
      end

      # Set the coordinates of the cursor.
      #
      # @param coords [Array<Fixnum>] The coordinates as a pair of integers
      # @return [Array<Fixnum>]
      # @note coordinates are 1-indexed
      # @example Move the cursor to line 1, column 2
      #   window.cursor.coordinates = [1, 2]
      def coordinates=(coords)
        @window.set_cursor(coords)
      end

      # Get the cursor's line number.
      #
      # @return [Fixnum]
      # @note Line numbers are 1-indexed
      def line
        coordinates[0]
      end

      # Set the cursor's line number.
      #
      # @param n [Fixnum]
      # @return [Fixnum]
      # @note Line numbers are 1-indexed
      def line=(n)
        self.coordinates = [n, column]
        n
      end

      # Get the cursor's column number.
      #
      # @return [Fixnum]
      # @note Column numbers are 1-indexed
      def column
        coordinates[1]
      end

      # Set the cursor's column number.
      #
      # @param n [Fixnum]
      # @return [Fixnum]
      # @note Column numbers are 1-indexed
      def column=(n)
        self.coordinates = [line, n]
        n
      end
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
