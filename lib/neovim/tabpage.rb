require "neovim/remote_object"

module Neovim
  # Class representing an +nvim+ tabpage.
  #
  # The methods documented here were generated using NVIM v0.3.0
  class Tabpage < RemoteObject
# The following methods are dynamically generated.
=begin
@method list_wins(tabpage)
  See +:h nvim_tabpage_list_wins()+
  @param [Tabpage] tabpage
  @return [Array<Window>]

@method get_var(tabpage, name)
  See +:h nvim_tabpage_get_var()+
  @param [Tabpage] tabpage
  @param [String] name
  @return [Object]

@method set_var(tabpage, name, value)
  See +:h nvim_tabpage_set_var()+
  @param [Tabpage] tabpage
  @param [String] name
  @param [Object] value
  @return [void]

@method del_var(tabpage, name)
  See +:h nvim_tabpage_del_var()+
  @param [Tabpage] tabpage
  @param [String] name
  @return [void]

@method get_win(tabpage)
  See +:h nvim_tabpage_get_win()+
  @param [Tabpage] tabpage
  @return [Window]

@method get_number(tabpage)
  See +:h nvim_tabpage_get_number()+
  @param [Tabpage] tabpage
  @return [Integer]

@method is_valid(tabpage)
  See +:h nvim_tabpage_is_valid()+
  @param [Tabpage] tabpage
  @return [Boolean]

=end
  end
end
