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

ENV["NVIM_RUBY_LOG_LEVEL"] ||= "FATAL"

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
      Timeout.timeout(timeout) do
        Support.clean_persistent_client
        spec.run
      end
    ensure
      Support.teardown_workspace
    end
  end

  config.before(:example, :nvim_version) do |spec|
    comparator = spec.metadata.fetch(:nvim_version)
    requirement = Gem::Requirement.create(comparator)

    nvim_version = Support
      .nvim_version
      .split("+")
      .first

    if !requirement.satisfied_by?(Gem::Version.new(nvim_version))
      skip "Skipping on nvim #{nvim_version} (requires #{comparator})"
    end
  end

  config.after(:suite) do
    Support.persistent_client.shutdown
  end

  Kernel.srand config.seed
end

Thread.abort_on_exception = true
