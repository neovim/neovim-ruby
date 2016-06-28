require "delegate"

class ClientDelegator < SimpleDelegator
  def Buffer
    ::Neovim::Buffer
  end

  def Window
    ::Neovim::Window
  end
end

module Neovim
  module VimCompatibility
    def self.wrap_client(client)
      begin
        Vim.__setobj__(client)
        yield
      ensure
        Vim.__setobj__(nil)
      end
    end
  end
end

Vim = ClientDelegator.new(nil)
