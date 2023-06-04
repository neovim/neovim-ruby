require "neovim/remote_object"

module Neovim
  # Class representing an +nvim+ tabpage.
  #
  # The methods documented here were generated using NVIM v0.9.1
  class Tabpage < RemoteObject
# The following methods are dynamically generated.
=begin
@method list_wins
  See +:h nvim_tabpage_list_wins()+
  @return [Array<Window>]

@method get_var(name)
  See +:h nvim_tabpage_get_var()+
  @param [String] name
  @return [Object]

@method set_var(name, value)
  See +:h nvim_tabpage_set_var()+
  @param [String] name
  @param [Object] value
  @return [void]

@method del_var(name)
  See +:h nvim_tabpage_del_var()+
  @param [String] name
  @return [void]

@method get_win
  See +:h nvim_tabpage_get_win()+
  @return [Window]

@method get_number
  See +:h nvim_tabpage_get_number()+
  @return [Integer]

@method is_valid
  See +:h nvim_tabpage_is_valid()+
  @return [Boolean]

=end
  end
end
