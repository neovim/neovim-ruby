module Support
  class << self
    attr_accessor :nvim_version
  end

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
    [Neovim.executable.path, "--headless", "-i", "NONE", "-u", "NONE", "-n"]
  end

  begin
    self.nvim_version = Neovim.executable.version
  rescue => e
    abort("Failed to load nvim: #{e}")
  end
end
