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

    # Get the buffer displayed in the window
    #
    # @return [Buffer]
    def buffer
      get_buffer
    end

    # Get the height of the window
    #
    # @return [Fixnum]
    def height
      get_height
    end

    # Set the height of the window
    #
    # @param height [Fixnum]
    # @return [Fixnum]
    def height=(height)
      set_height(height)
      height
    end

    # Get the width of the window
    #
    # @return [Fixnum]
    def width
      get_width
    end

    # Set the width of the window
    #
    # @param width [Fixnum]
    # @return [Fixnum]
    def width=(width)
      set_width(width)
      width
    end

    # Get the cursor coordinates
    #
    # @return [Array(Fixnum, Fixnum)]
    def cursor
      get_cursor
    end

    # Set the cursor coodinates
    #
    # @param coords [Array(Fixnum, Fixnum)]
    # @return [Array(Fixnum, Fixnum)]
    def cursor=(coords)
      set_cursor(coords)
    end

# The following methods are dynamically generated.
=begin
@method get_buffer
  @return [Buffer]

@method get_cursor
  @return [Array<Fixnum>]

@method set_cursor(pos)
  @param [Array<Fixnum>] pos
  @return [void]

@method get_height
  @return [Fixnum]

@method set_height(height)
  @param [Fixnum] height
  @return [void]

@method get_width
  @return [Fixnum]

@method set_width(width)
  @param [Fixnum] width
  @return [void]

@method get_var(name)
  @param [String] name
  @return [Object]

@method set_var(name, value)
  @param [String] name
  @param [Object] value
  @return [Object]

@method get_option(name)
  @param [String] name
  @return [Object]

@method set_option(name, value)
  @param [String] name
  @param [Object] value
  @return [void]

@method get_position
  @return [Array<Fixnum>]

@method get_tabpage
  @return [Tabpage]

@method is_valid
  @return [Boolean]

=end
  end
end
