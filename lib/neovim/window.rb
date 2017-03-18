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
    # @return [Integer]
    def height
      get_height
    end

    # Set the height of the window
    #
    # @param height [Integer]
    # @return [Integer]
    def height=(height)
      set_height(height)
      height
    end

    # Get the width of the window
    #
    # @return [Integer]
    def width
      get_width
    end

    # Set the width of the window
    #
    # @param width [Integer]
    # @return [Integer]
    def width=(width)
      set_width(width)
      width
    end

    # Get the cursor coordinates
    #
    # @return [Array(Integer, Integer)]
    def cursor
      get_cursor
    end

    # Set the cursor coodinates
    #
    # @param coords [Array(Integer, Integer)]
    # @return [Array(Integer, Integer)]
    def cursor=(coords)
      _x, _y = coords
      x = [_x, 1].max
      y = [_y, 0].max + 1
      @session.request(:vim_eval, "cursor(#{x}, #{y})")
    end

# The following methods are dynamically generated.
=begin
@method set_var(name, value)
  Send the +window_set_var+ RPC to +nvim+
  @param [String] name
  @param [Object] value
  @return [Object]

@method del_var(name)
  Send the +window_del_var+ RPC to +nvim+
  @param [String] name
  @return [Object]

@method get_buffer
  Send the +window_get_buffer+ RPC to +nvim+
  @return [Buffer]

@method get_cursor
  Send the +window_get_cursor+ RPC to +nvim+
  @return [Array<Integer>]

@method set_cursor(pos)
  Send the +window_set_cursor+ RPC to +nvim+
  @param [Array<Integer>] pos
  @return [void]

@method get_height
  Send the +window_get_height+ RPC to +nvim+
  @return [Integer]

@method set_height(height)
  Send the +window_set_height+ RPC to +nvim+
  @param [Integer] height
  @return [void]

@method get_width
  Send the +window_get_width+ RPC to +nvim+
  @return [Integer]

@method set_width(width)
  Send the +window_set_width+ RPC to +nvim+
  @param [Integer] width
  @return [void]

@method get_var(name)
  Send the +window_get_var+ RPC to +nvim+
  @param [String] name
  @return [Object]

@method get_option(name)
  Send the +window_get_option+ RPC to +nvim+
  @param [String] name
  @return [Object]

@method set_option(name, value)
  Send the +window_set_option+ RPC to +nvim+
  @param [String] name
  @param [Object] value
  @return [void]

@method get_position
  Send the +window_get_position+ RPC to +nvim+
  @return [Array<Integer>]

@method get_tabpage
  Send the +window_get_tabpage+ RPC to +nvim+
  @return [Tabpage]

@method is_valid
  Send the +window_is_valid+ RPC to +nvim+
  @return [Boolean]

=end
  end
end
