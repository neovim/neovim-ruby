require "rubygems"
require "bundler/setup"
require "neovim"

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.order = :random
end

RSpec.shared_examples "Requiring a remote Neovim process", :remote => true do
  let!(:client) do
    begin
      Neovim::Client.new("/tmp/neovim.sock").command("cq")
    rescue Errno::ENOENT
      retry
    end

    begin
      Neovim::Client.new("/tmp/neovim.sock")
    rescue
      retry
    end
  end
end
