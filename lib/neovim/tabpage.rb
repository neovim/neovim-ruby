require "neovim/remote_object"

module Neovim
  # Class representing an +nvim+ tabpage.
  #
  # The methods documented here were generated using NVIM v0.1.7
  class Tabpage < RemoteObject

# The following methods are dynamically generated.
=begin
@method set_var(name, value)
  Send the +tabpage_set_var+ RPC to +nvim+
  @param [String] name
  @param [Object] value
  @return [Object]

@method del_var(name)
  Send the +tabpage_del_var+ RPC to +nvim+
  @param [String] name
  @return [Object]

@method get_windows
  Send the +tabpage_get_windows+ RPC to +nvim+
  @return [Array<Window>]

@method get_var(name)
  Send the +tabpage_get_var+ RPC to +nvim+
  @param [String] name
  @return [Object]

@method get_window
  Send the +tabpage_get_window+ RPC to +nvim+
  @return [Window]

@method is_valid
  Send the +tabpage_is_valid+ RPC to +nvim+
  @return [Boolean]

=end
  end
end
