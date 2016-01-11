require "bundler/setup"
require "logger"
require "neovim"
require "pry"
require "timeout"

if ENV["REPORT_COVERAGE"]
  require "coveralls"
  Coveralls.wear!
end

Thread.abort_on_exception = true

ENV["NVIM_EXECUTABLE"] = File.expand_path("../../vendor/neovim/build/bin/nvim", __FILE__)

Neovim.logger = Logger.new(STDERR)
Neovim.logger.level = Logger::WARN

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
