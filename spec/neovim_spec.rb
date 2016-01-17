require "neovim/plugin"
require "helper"
require "fileutils"

RSpec.describe Neovim do
  let(:nvim_exe) { ENV.fetch("NVIM_EXECUTABLE") }
  let(:nvim_argv) { %w(--headless -u NONE -i NONE -N -n) }

  describe ".attach_tcp" do
    it "attaches to a TCP socket" do
      srv = TCPServer.new("0.0.0.0", 0)
      port = srv.addr[1]
      srv.close

      env = {"NVIM_LISTEN_ADDRESS" => "0.0.0.0:#{port}"}
      pid = Process.spawn(env, nvim_exe, *nvim_argv, [:out, :err] => "/dev/null")

      begin
        wait_socket = TCPSocket.open("0.0.0.0", port)
      rescue Errno::ECONNREFUSED
        retry
      end
      wait_socket.close

      begin
        expect(Neovim.attach_tcp("0.0.0.0", port).strwidth("hi")).to eq(2)
      ensure
        Process.kill(:TERM, pid)
      end
    end
  end

  describe ".attach_unix" do
    it "attaches to a UNIX socket" do
      env = {"NVIM_LISTEN_ADDRESS" => Support.socket_path}
      pid = Process.spawn(env, nvim_exe, *nvim_argv, [:out, :err] => "/dev/null")

      loop { break if File.exists?(Support.socket_path) }

      begin
        expect(Neovim.attach_unix(Support.socket_path).strwidth("hi")).to eq(2)
      ensure
        Process.kill(:TERM, pid)
      end
    end
  end

  describe ".attach_child" do
    it "spawns and attaches to a child process" do
      nvim = Neovim.attach_child(nvim_argv)
      expect(nvim.strwidth("hi")).to eq(2)
    end
  end

  describe ".plugin" do
    it "registers the plugin to Neovim.__configured_plugin_manifest" do
      mock_manifest = double(:manifest)
      mock_plugin = double(:plugin)
      mock_path = "/source/path"

      allow(Neovim).to receive(:__configured_plugin_path).and_return(mock_path)
      allow(Neovim).to receive(:__configured_plugin_manifest).and_return(mock_manifest)

      expect(Neovim::Plugin).to receive(:from_config_block).with(mock_path).and_return(mock_plugin)
      expect(mock_manifest).to receive(:register).with(mock_plugin)

      Neovim.plugin
    end
  end
end
