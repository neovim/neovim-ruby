require "neovim/remote_object"

module Neovim
  # Class representing an +nvim+ window.
  #
  # The methods documented here were generated using NVIM v0.2.0
  class Window < RemoteObject
    # Get the buffer displayed in the window
    #
    # @return [Buffer]
    def buffer
      get_buf
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
      @session.request(:nvim_eval, "cursor(#{x}, #{y})")
    end

# The following methods are dynamically generated.
=begin
@method get_buf(window)
  See +:h nvim_win_get_buf()+
  @param [Window] window
  @return [Buffer]

@method get_cursor(window)
  See +:h nvim_win_get_cursor()+
  @param [Window] window
  @return [Array<Integer>]

@method set_cursor(window, pos)
  See +:h nvim_win_set_cursor()+
  @param [Window] window
  @param [Array<Integer>] pos
  @return [void]

@method get_height(window)
  See +:h nvim_win_get_height()+
  @param [Window] window
  @return [Integer]

@method set_height(window, height)
  See +:h nvim_win_set_height()+
  @param [Window] window
  @param [Integer] height
  @return [void]

@method get_width(window)
  See +:h nvim_win_get_width()+
  @param [Window] window
  @return [Integer]

@method set_width(window, width)
  See +:h nvim_win_set_width()+
  @param [Window] window
  @param [Integer] width
  @return [void]

@method get_var(window, name)
  See +:h nvim_win_get_var()+
  @param [Window] window
  @param [String] name
  @return [Object]

@method set_var(window, name, value)
  See +:h nvim_win_set_var()+
  @param [Window] window
  @param [String] name
  @param [Object] value
  @return [void]

@method del_var(window, name)
  See +:h nvim_win_del_var()+
  @param [Window] window
  @param [String] name
  @return [void]

@method get_option(window, name)
  See +:h nvim_win_get_option()+
  @param [Window] window
  @param [String] name
  @return [Object]

@method set_option(window, name, value)
  See +:h nvim_win_set_option()+
  @param [Window] window
  @param [String] name
  @param [Object] value
  @return [void]

@method get_position(window)
  See +:h nvim_win_get_position()+
  @param [Window] window
  @return [Array<Integer>]

@method get_tabpage(window)
  See +:h nvim_win_get_tabpage()+
  @param [Window] window
  @return [Tabpage]

@method get_number(window)
  See +:h nvim_win_get_number()+
  @param [Window] window
  @return [Integer]

@method is_valid(window)
  See +:h nvim_win_is_valid()+
  @param [Window] window
  @return [Boolean]

=end
  end
end
