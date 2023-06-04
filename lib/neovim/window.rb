require "neovim/remote_object"

module Neovim
  # Class representing an +nvim+ window.
  #
  # The methods documented here were generated using NVIM v0.9.1
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
      x, y = coords
      x = [x, 1].max
      y = [y, 0].max + 1
      @session.request(:nvim_eval, "cursor(#{x}, #{y})")
    end

# The following methods are dynamically generated.
=begin
@method get_option(name)
  See +:h nvim_win_get_option()+
  @param [String] name
  @return [Object]

@method set_option(name, value)
  See +:h nvim_win_set_option()+
  @param [String] name
  @param [Object] value
  @return [void]

@method set_config(config)
  See +:h nvim_win_set_config()+
  @param [Hash] config
  @return [void]

@method get_config
  See +:h nvim_win_get_config()+
  @return [Hash]

@method get_buf
  See +:h nvim_win_get_buf()+
  @return [Buffer]

@method set_buf(buffer)
  See +:h nvim_win_set_buf()+
  @param [Buffer] buffer
  @return [void]

@method get_cursor
  See +:h nvim_win_get_cursor()+
  @return [Array<Integer>]

@method set_cursor(pos)
  See +:h nvim_win_set_cursor()+
  @param [Array<Integer>] pos
  @return [void]

@method get_height
  See +:h nvim_win_get_height()+
  @return [Integer]

@method set_height(height)
  See +:h nvim_win_set_height()+
  @param [Integer] height
  @return [void]

@method get_width
  See +:h nvim_win_get_width()+
  @return [Integer]

@method set_width(width)
  See +:h nvim_win_set_width()+
  @param [Integer] width
  @return [void]

@method get_var(name)
  See +:h nvim_win_get_var()+
  @param [String] name
  @return [Object]

@method set_var(name, value)
  See +:h nvim_win_set_var()+
  @param [String] name
  @param [Object] value
  @return [void]

@method del_var(name)
  See +:h nvim_win_del_var()+
  @param [String] name
  @return [void]

@method get_position
  See +:h nvim_win_get_position()+
  @return [Array<Integer>]

@method get_tabpage
  See +:h nvim_win_get_tabpage()+
  @return [Tabpage]

@method get_number
  See +:h nvim_win_get_number()+
  @return [Integer]

@method is_valid
  See +:h nvim_win_is_valid()+
  @return [Boolean]

@method hide
  See +:h nvim_win_hide()+
  @return [void]

@method close(force)
  See +:h nvim_win_close()+
  @param [Boolean] force
  @return [void]

@method call(fun)
  See +:h nvim_win_call()+
  @param [LuaRef] fun
  @return [Object]

@method set_hl_ns(ns_id)
  See +:h nvim_win_set_hl_ns()+
  @param [Integer] ns_id
  @return [void]

=end
  end
end
