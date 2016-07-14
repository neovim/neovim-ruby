require "helper"

RSpec.describe Neovim do
  let(:nvim_argv) { %w(nvim --embed -u NONE -i NONE -n) }

  describe ".attach_tcp" do
    it "attaches to a TCP socket" do
      port = Support.port
      env = {"NVIM_LISTEN_ADDRESS" => "0.0.0.0:#{port}"}
      pid = Process.spawn(env, *nvim_argv, [:out, :err] => "/dev/null")
      Process.detach(pid)

      begin
        TCPSocket.open("0.0.0.0", port).close
      rescue Errno::ECONNREFUSED
        retry
      end

      expect(Neovim.attach_tcp("0.0.0.0", port).strwidth("hi")).to eq(2)
    end
  end

  describe ".attach_unix" do
    it "attaches to a UNIX socket" do
      socket_path = Support.socket_path
      env = {"NVIM_LISTEN_ADDRESS" => socket_path}
      pid = Process.spawn(env, *nvim_argv, [:out, :err] => "/dev/null")
      Process.detach(pid)

      begin
        UNIXSocket.new(socket_path).close
      rescue Errno::ENOENT, Errno::ECONNREFUSED
        retry
      end

      expect(Neovim.attach_unix(socket_path).strwidth("hi")).to eq(2)
    end
  end

  describe ".attach_child" do
    it "spawns and attaches to a child process" do
      expect(Neovim.attach_child(nvim_argv).strwidth("hi")).to eq(2)
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
