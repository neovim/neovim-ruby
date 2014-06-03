require "rubygems"
require "bundler/setup"
require "rspec/autorun"
require "neovim"

RSpec.shared_examples "Requiring a remote Neovim process", :remote => true do
  before do
    Neovim::Client.new("/tmp/neovim.sock").commands(
      "1,$d",
      "set all&",
      "set noswapfile",
      "for var in keys(g:)",
      "  exec \"unlet g:\" . var",
      "endfor",
      "for var in keys(b:)",
      "  exec \"unlet b:\" . var",
      "endfor"
    )
  end
end
