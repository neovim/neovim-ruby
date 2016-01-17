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

  def self.remove_workspace
    FileUtils.rm_rf(workspace)
  end

  def self.clean_workspace
    remove_workspace
    FileUtils.mkdir_p(workspace)
  end
end
