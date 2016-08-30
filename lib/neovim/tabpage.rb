require "neovim/remote_object"

module Neovim
  class Tabpage < RemoteObject

# The following methods are dynamically generated.
=begin
@method get_windows
  Send the +get_windows+ RPC to +nvim+
  @return [Array<Window>]

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

@method get_window
  Send the +get_window+ RPC to +nvim+
  @return [Window]

@method is_valid
  Send the +is_valid+ RPC to +nvim+
  @return [Boolean]

=end
  end
end
