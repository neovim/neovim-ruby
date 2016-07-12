require "neovim/buffer"
require "neovim/window"

module VIM
  Buffer = ::Neovim::Buffer
  Window = ::Neovim::Window

  def self.__client=(client)
    @__client = client
  end

  def self.method_missing(method, *args, &block)
    @__client.public_send(method, *args, &block)
  end
end
