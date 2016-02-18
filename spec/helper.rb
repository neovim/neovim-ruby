require "bundler/setup"
require "logger"
require "neovim"
require "pry"
require "timeout"

require File.expand_path("../support.rb", __FILE__)

if ENV["REPORT_COVERAGE"]
  require "coveralls"
  Coveralls.wear!
end

Thread.abort_on_exception = true

ENV["NVIM_EXECUTABLE"] = File.expand_path("../../vendor/neovim/build/bin/nvim", __FILE__)

Neovim.logger = Logger.new(STDERR).tap do |logger|
  logger.level = ENV.fetch("NVIM_RUBY_LOG_LEVEL", Logger::WARN).to_i
end

RSpec.configure do |config|
  config.expect_with :rspec do |exp|
    exp.syntax = :expect
  end

  config.disable_monkey_patching!
  config.order = :random

  Kernel.srand config.seed

  config.around(:example) do |spec|
    Support.clean_workspace
    Timeout.timeout(2) { spec.run }
  end

  config.after(:suite) do
    Support.remove_workspace
  end
end
