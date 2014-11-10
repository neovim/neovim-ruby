require "rubygems"
require "bundler/setup"
require "neovim"

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.order = :random
end

RSpec.shared_examples :remote => true do
  around do |spec|
    retry_exceptions = [
      Errno::ENOENT,
      Errno::ECONNREFUSED,
      Errno::EPIPE,
      Errno::ECONNRESET,
      EOFError
    ]

    nvim = File.expand_path("../../vendor/neovim/build/bin/nvim", __FILE__)

    IO.popen("#{nvim} --embed -u NONE -i NONE -N -n", "rb+") do |io|
      nvim_pid = io.pid
      @client = Neovim::Client.new(io)

      begin
        spec.run
      ensure
        Process.kill(:TERM, nvim_pid)
        Process.waitpid2(nvim_pid)
      end
    end
  end
end
