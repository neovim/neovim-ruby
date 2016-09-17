require "neovim/buffer"
require "neovim/window"

# The VIM module provides backwards compatibility for the legacy +:ruby+,
# +:rubyfile+, and +:rubydo+ +vim+ functions.
module Vim
  Buffer = ::Neovim::Buffer
  Window = ::Neovim::Window

  def self.__client=(client)
    @__client = client
  end

  # Delegate all method calls to the underlying +Neovim::Client+ object.
  def self.method_missing(method, *args, &block)
    @__client.public_send(method, *args, &block)
  end
end

VIM = Vim
