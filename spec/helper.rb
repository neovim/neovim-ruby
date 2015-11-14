require "rubygems"
require "bundler/setup"
require "neovim"
require "timeout"
require "pry"

if ENV["REPORT_COVERAGE"]
  require "coveralls"
  Coveralls.wear!
end

ENV["NVIM_EXECUTABLE"] = File.expand_path("../../vendor/neovim/build/bin/nvim", __FILE__)

RSpec.configure do |config|
  config.expect_with :rspec do |exp|
    exp.syntax = :expect
  end

  config.disable_monkey_patching!
  config.order = :random

  Kernel.srand config.seed

  config.around do |spec|
    Timeout.timeout(5) { spec.run }
  end
end
