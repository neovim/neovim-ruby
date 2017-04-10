require "bundler/setup"

if ENV["REPORT_COVERAGE"]
  require "coveralls"
  Coveralls.wear!
end

require "fileutils"
require "neovim"
require "pry"
require "shellwords"
require "stringio"
require "timeout"

module Support
  def self.workspace
    File.expand_path("../workspace", __FILE__)
  end

  def self.socket_path
    file_path("nvim.sock")
  end

  def self.tcp_port
    server = TCPServer.new("127.0.0.1", 0)

    begin
      server.addr[1]
    ensure
      server.close
    end
  end

  def self.file_path(name)
    File.join(workspace, name)
  end

  def self.setup_workspace
    FileUtils.mkdir_p(workspace)
  end

  def self.teardown_workspace
    FileUtils.rm_rf(workspace)
  end

  def self.child_argv
    nvim_exe = ENV.fetch("NVIM_EXECUTABLE", "nvim")
    [nvim_exe, "--headless", "-i", "NONE", "-u", "NONE", "-n"]
  end
end

IO.popen([*Support.child_argv, "--version"]) do |io|
  NVIM_VERSION = io.gets[/\ANVIM v?(.+)$/, 1]
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
      Timeout.timeout(5) { spec.run }
    ensure
      Support.teardown_workspace
    end
  end

  config.around(:example, :silence_warnings) do |spec|
    old_logger = Neovim.logger
    log_target = StringIO.new
    Neovim.logger = Logger.new(log_target)
    Neovim.logger.level = Logger::WARN

    begin
      spec.run

      expect(log_target.string).not_to be_empty,
        ":silence_warnings used but nothing logged at WARN level"
    ensure
      Neovim.logger = old_logger
    end
  end

  config.before(:example, :nvim_version) do |spec|
    vrs = Gem::Version.new(NVIM_VERSION)
    req = Gem::Requirement.new(spec.metadata[:nvim_version])

    unless req.satisfied_by?(vrs)
      pending "Pending: installed nvim (#{vrs}) doesn't satisfy '#{req}'."
    end
  end

  Kernel.srand config.seed
end

Thread.abort_on_exception = true
