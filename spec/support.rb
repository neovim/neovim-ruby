require "shellwords"

module Support
  class << self
    attr_accessor :nvim_version
  end

  def self.clean_persistent_client
    persistent_client.command("%bdelete! | tabonly | only | set all&")
  end

  def self.backend_strategy
    @backend_strategy ||= ENV.fetch("NVIM_RUBY_SPEC_BACKEND", "child")
  end

  def self.persistent_client
    return @persistent_client if defined?(@persistent_client)

    case backend_strategy
    when /^child:?(.*)$/
      @persistent_client = Neovim.attach_child(child_argv + Shellwords.split($1))
    when /^tcp:(.+)$/
      @persistent_client = Neovim.attach_tcp(*$1.split(":", 2))
    when /^unix:(.+)$/
      @persistent_client = Neovim.attach_unix($1)
    else
      raise "Unrecognized $NVIM_RUBY_SPEC_BACKEND #{backend_strategy.inspect}"
    end
  end

  def self.workspace
    File.expand_path("workspace", __dir__)
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
    [Neovim.executable.path, "--headless", "-i", "NONE", "-u", "NONE", "-n"]
  end

  def self.windows?
    Gem.win_platform?
  end

  def self.kill(pid)
    windows? ? Process.kill(:KILL, pid) : Process.kill(:TERM, pid)
    Process.waitpid(pid)
  end

  begin
    self.nvim_version = Neovim.executable.version
  rescue => e
    abort("Failed to load nvim: #{e}")
  end
end
