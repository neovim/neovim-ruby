require "rubygems"
require "bundler/setup"
require "neovim"

working_directory = File.expand_path("../..", __FILE__)

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.order = :random
end

RSpec.shared_examples "Requiring a remote Neovim process", :remote => true do
  before do
    Neovim::Client.new("/tmp/neovim.sock").commands(
      "1,$d",
      "cd #{working_directory}",
      "set all&",
      "vert resize",
      "resize",
      "wincmd p",
      "only",
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
