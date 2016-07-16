require "helper"

RSpec.describe Neovim do
  let(:nvim_argv) { %w(nvim --headless -u NONE -i NONE -n) }

  describe ".attach_tcp" do
    it "attaches to a TCP socket" do
      port = Support.port
      env = {"NVIM_LISTEN_ADDRESS" => "0.0.0.0:#{port}"}
      pid = Process.spawn(env, *nvim_argv, [:out, :err] => "/dev/null")

      begin
        TCPSocket.open("0.0.0.0", port).close
      rescue Errno::ECONNREFUSED
        retry
      end

      begin
        expect(Neovim.attach_tcp("0.0.0.0", port).strwidth("hi")).to eq(2)
      ensure
        Process.kill(:TERM, pid)
        Process.waitpid(pid)
      end
    end
  end

  describe ".attach_unix" do
    it "attaches to a UNIX socket" do
      socket_path = Support.socket_path
      env = {"NVIM_LISTEN_ADDRESS" => socket_path}
      pid = Process.spawn(env, *nvim_argv, [:out, :err] => "/dev/null")

      begin
        UNIXSocket.new(socket_path).close
      rescue Errno::ENOENT, Errno::ECONNREFUSED
        retry
      end

      begin
        expect(Neovim.attach_unix(socket_path).strwidth("hi")).to eq(2)
      ensure
        Process.kill(:TERM, pid)
        Process.waitpid(pid)
      end
    end
  end

  describe ".attach_child" do
    it "spawns and attaches to a child process" do
      begin
        client = Neovim.attach_child(nvim_argv)
        expect(client.strwidth("hi")).to eq(2)
      ensure
        client.shutdown
      end
    end
  end

  describe ".start_host" do
    it "loads and runs a Host" do
      host = double(:host)
      paths = ["/foo", "/bar"]

      expect(Neovim::Host).to receive(:new).and_return(host)
      expect(host).to receive(:load_files).with(paths)
      expect(host).to receive(:run)

      Neovim.start_host(paths)
    end
  end

  describe ".plugin" do
    it "loads a plugin and registers it to the host" do
      host = double(:host, :plugin_path => "/foo/bar")
      plugin = double(:plugin)
      allow(Neovim).to receive(:plugin_host).and_return(host)

      expect(Neovim::Plugin).to receive(:from_config_block).
        with("/foo/bar").
        and_return(plugin)

      expect(host).to receive(:register).with(plugin)

      Neovim.plugin
    end

    it "raises an exception outside of a plugin host" do
      expect {
        Neovim.plugin
      }.to raise_error(/outside of a plugin host/i)
    end
  end
end
