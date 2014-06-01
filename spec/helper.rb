require "rubygems"
require "bundler/setup"
require "rspec/autorun"

RSpec.shared_examples "Remote Neovim process", :remote => true do
  before do
    Neovim::Client.new("/tmp/neovim.sock").command(
      "set all& | " +
      "for var in keys(g:) | " +
      "  exec \"unlet g:\".var | " +
      "endfor | " +
      "enew!"
    )
  end
end
