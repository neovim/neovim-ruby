require "bundler/setup"
require "logger"
require "mkmf"
require "neovim"
require "pry"
require "timeout"

require File.expand_path("../support.rb", __FILE__)

if ENV["REPORT_COVERAGE"]
  require "coveralls"
  Coveralls.wear!
end

unless find_executable0("nvim")
  warn("Can't find `nvim` executable. See installation instructions:")
  warn("https://github.com/neovim/neovim/wiki/Installing-Neovim")
  exit(1)
end

RSpec.configure do |config|
  config.expect_with :rspec do |exp|
    exp.syntax = :expect
  end

  config.disable_monkey_patching!
  config.order = :random
  config.color = true

  config.around(:example) do |spec|
    Support.setup_workspace

    begin
      Timeout.timeout(2) { spec.run }
    ensure
      Support.teardown_workspace
    end
  end

  Kernel.srand config.seed
end

Thread.abort_on_exception = true
