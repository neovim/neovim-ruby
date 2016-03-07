require "fileutils"

module Support
  def self.workspace
    File.expand_path("../workspace/#$$", __FILE__)
  end

  def self.socket_path
    file_path("nvim.sock")
  end

  def self.port
    server = TCPServer.new("0.0.0.0", 0)
    server.addr[1].tap { server.close }
  end

  def self.file_path(name)
    File.join(workspace, name)
  end

  def self.setup_workspace
    teardown_workspace
    FileUtils.mkdir_p(workspace)
  end

  def self.teardown_workspace
    FileUtils.rm_rf(workspace)
  end
end