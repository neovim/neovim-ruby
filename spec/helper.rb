require "bundler/setup"

if ENV["REPORT_COVERAGE"]
  require "coveralls"
  Coveralls.wear!
end

require "fileutils"
require "neovim"
require "pry"
require "rubygems"
require "stringio"
require "timeout"
require "securerandom"
require "msgpack"

require File.expand_path("../support.rb", __FILE__)

RSpec.configure do |config|
  config.expect_with :rspec do |exp|
    exp.syntax = :expect
  end

  config.disable_monkey_patching!
  config.order = :random
  config.color = true

  config.around(:example) do |spec|
    Support.setup_workspace
    timeout = spec.metadata.fetch(:timeout, 3)

    begin
      Timeout.timeout(timeout) { spec.run }
    ensure
      Support.teardown_workspace
    end
  end

  Kernel.srand config.seed
end

Thread.abort_on_exception = true
