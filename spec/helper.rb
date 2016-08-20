require "bundler/setup"
require "neovim"
require "pry"
require "stringio"
require "timeout"
require "fileutils"

if ENV["REPORT_COVERAGE"]
  require "coveralls"
  Coveralls.wear!
end

unless system("nvim -nu NONE +q")
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

module Support
  def self.workspace
    File.expand_path("../workspace", __FILE__)
  end

  def self.socket_path
    file_path("nvim.sock")
  end

  def self.port
    server = TCPServer.new("0.0.0.0", 0)

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
end

Thread.abort_on_exception = true
