require "bundler/setup"

require "fileutils"
require "msgpack"
require "neovim"
require "pry"
require "rubygems"
require "securerandom"
require "stringio"
require "timeout"

require File.expand_path("support.rb", __dir__)

RSpec.configure do |config|
  config.expect_with :rspec do |exp|
    exp.syntax = :expect
  end

  config.disable_monkey_patching!
  config.order = :random
  config.color = true

  config.around(:example, :silence_thread_exceptions) do |spec|
    if Thread.respond_to?(:report_on_exception)
      original = Thread.report_on_exception

      begin
        Thread.report_on_exception = false
        spec.run
      ensure
        Thread.report_on_exception = original
      end
    else
      spec.run
    end
  end

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
