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

nvim_bin = File.expand_path("../../vendor/neovim/build/bin/nvim", __FILE__)

if File.exists?(nvim_bin)
  ENV["NVIM_EXECUTABLE"] = nvim_bin
else
  warn("Can't find vendored `nvim` executable. Build it with `rake neovim:build`")
  exit(1)
end

Neovim.logger = Logger.new(STDERR).tap do |logger|
  logger.level = ENV.fetch("NVIM_RUBY_LOG_LEVEL", Logger::WARN).to_i
end

RSpec.configure do |config|
  config.expect_with :rspec do |exp|
    exp.syntax = :expect
  end

  config.disable_monkey_patching!
  config.order = :random
  config.color = true

  Kernel.srand config.seed

  config.around(:example) do |spec|
    Support.setup_workspace
    Timeout.timeout(2) { spec.run }
  end

  config.after(:suite) do
    Support.teardown_workspace
  end
end
