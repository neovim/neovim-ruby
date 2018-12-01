require "neovim/buffer"
require "neovim/window"

# The VIM module provides backwards compatibility for the +:ruby+, +:rubyfile+,
# and +:rubydo+ +vim+ functions.
module Vim
  Buffer = ::Neovim::Buffer
  Window = ::Neovim::Window

  @__buffer_cache = {}

  def self.__client=(client)
    @__client = client
  end

  # Delegate all method calls to the underlying +Neovim::Client+ object.
  def self.method_missing(method, *args, &block)
    if @__client.respond_to?(method)
      resp = nil
      @__client.run_par [
        lambda { resp = @__client.public_send(method, *args, &block) },
        method(:refresh_curbuf),
        method(:refresh_curwin),
      ]
      resp
    else
      super
    end
  end

  def self.respond_to_missing?(method, *args)
    if @__client
      @__client.send(:respond_to_missing?, method, *args)
    else
      super
    end
  end

  def self.refresh_curbuf
    bufnr = @__client.evaluate("bufnr('%')")
    $curbuf = @__buffer_cache.fetch(bufnr) do
      @__buffer_cache[bufnr] = @__client.get_current_buf
    end
  end

  def self.refresh_curwin
    $curwin = @__client.get_current_win
  end
end

VIM = Vim
