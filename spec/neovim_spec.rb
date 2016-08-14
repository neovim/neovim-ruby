require "helper"

RSpec.describe Neovim do
  let(:nvim_argv) { %w(nvim --headless -u NONE -i NONE -n) }

  describe ".attach_tcp" do
    it "attaches to a TCP socket" do
      port = Support.port
      env = {"NVIM_LISTEN_ADDRESS" => "0.0.0.0:#{port}"}
      pid = Process.spawn(env, *nvim_argv, [:out, :err] => "/dev/null")

      begin
        client = Neovim.attach_tcp("0.0.0.0", port)
      rescue Errno::ECONNREFUSED
        retry
      end

      begin
        expect(client.strwidth("hi")).to eq(2)
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
        client = Neovim.attach_unix(socket_path)
      rescue Errno::ENOENT, Errno::ECONNREFUSED
        retry
      end

      begin
        expect(client.strwidth("hi")).to eq(2)
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
      paths = ["/foo", "/bar"]
      host = double(:host)

      expect(Neovim::Host).to receive(:load_from_files).
        with(paths).
        and_return(host)

      expect(host).to receive(:run)
      Neovim.start_host(paths)
    end
  end
end
