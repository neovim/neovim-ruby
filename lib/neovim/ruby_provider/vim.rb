require "neovim/buffer"
require "neovim/window"

# The VIM module provides backwards compatibility for the legacy +:ruby+,
# +:rubyfile+, and +:rubydo+ +vim+ functions.
module Vim
  Buffer = ::Neovim::Buffer
  Window = ::Neovim::Window

  @__buffer_cache = {}

  def self.__client=(client)
    @__client = client
  end

  # Delegate all method calls to the underlying +Neovim::Client+ object.
  def self.method_missing(method, *args, &block)
    @__client.public_send(method, *args, &block).tap do
      __refresh_globals(@__client)
    end
  end

  def self.__refresh_globals(client)
    bufnr = client.evaluate("bufnr('%')")

    $curbuf = @__buffer_cache.fetch(bufnr) do
      @__buffer_cache[bufnr] = client.get_current_buffer
    end

    $curwin = client.get_current_window
  end
end

VIM = Vim
