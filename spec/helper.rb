require "rubygems"
require "bundler/setup"
require "rspec/autorun"

RSpec.shared_examples "Requiring a remote Neovim process", :remote => true do
  before do
    Neovim::Client.new("/tmp/neovim.sock").commands(
      "1,$d",
      "set all&",
      "for var in keys(g:)",
      "  exec \"unlet g:\" . var",
      "endfor"
    )
  end
end
