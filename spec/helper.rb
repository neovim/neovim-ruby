require "rubygems"
require "bundler/setup"
require "neovim"
require "timeout"

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.order = :random
end

RSpec.shared_examples :remote => true do
  let!(:client) do
    retry_exceptions = [
      Errno::ENOENT,
      Errno::ECONNREFUSED,
      Errno::EPIPE,
      Errno::ECONNRESET,
      EOFError
    ]

    begin
      Neovim::Client.new("/tmp/neovim.sock").command("cq")
    rescue *retry_exceptions
      retry
    end

    begin
      Neovim::Client.new("/tmp/neovim.sock")
    rescue *retry_exceptions
      retry
    end
  end
end
