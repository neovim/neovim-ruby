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

unless system("#{Support.child_argv.shelljoin} --version | grep -q NVIM")
  warn("Failed to load nvim. See installation instructions:")
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
      Timeout.timeout(5) { spec.run }
    ensure
      Support.teardown_workspace
    end
  end

  config.around(:example, :silence_logging) do |spec|
    old_logger = Neovim.logger

    begin
      Neovim.logger = Logger.new(StringIO.new)
      spec.run
    ensure
      Neovim.logger = old_logger
    end
  end

  Kernel.srand config.seed
end

Thread.abort_on_exception = true
