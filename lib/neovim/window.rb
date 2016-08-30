require "neovim/remote_object"

module Neovim
  class Window < RemoteObject
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
  Send the +get_buffer+ RPC to +nvim+
  @return [Buffer]

@method get_cursor
  Send the +get_cursor+ RPC to +nvim+
  @return [Array<Fixnum>]

@method set_cursor(pos)
  Send the +set_cursor+ RPC to +nvim+
  @param [Array<Fixnum>] pos
  @return [void]

@method get_height
  Send the +get_height+ RPC to +nvim+
  @return [Fixnum]

@method set_height(height)
  Send the +set_height+ RPC to +nvim+
  @param [Fixnum] height
  @return [void]

@method get_width
  Send the +get_width+ RPC to +nvim+
  @return [Fixnum]

@method set_width(width)
  Send the +set_width+ RPC to +nvim+
  @param [Fixnum] width
  @return [void]

@method get_var(name)
  Send the +get_var+ RPC to +nvim+
  @param [String] name
  @return [Object]

@method set_var(name, value)
  Send the +set_var+ RPC to +nvim+
  @param [String] name
  @param [Object] value
  @return [Object]

@method del_var(name)
  Send the +del_var+ RPC to +nvim+
  @param [String] name
  @return [Object]

@method get_option(name)
  Send the +get_option+ RPC to +nvim+
  @param [String] name
  @return [Object]

@method set_option(name, value)
  Send the +set_option+ RPC to +nvim+
  @param [String] name
  @param [Object] value
  @return [void]

@method get_position
  Send the +get_position+ RPC to +nvim+
  @return [Array<Fixnum>]

@method get_tabpage
  Send the +get_tabpage+ RPC to +nvim+
  @return [Tabpage]

@method is_valid
  Send the +is_valid+ RPC to +nvim+
  @return [Boolean]

=end
  end
end
