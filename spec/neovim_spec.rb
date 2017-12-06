require "helper"

RSpec.describe Neovim do
  describe ".attach_tcp" do
    it "attaches to a TCP socket" do
      port = Support.tcp_port
      env = {"NVIM_LISTEN_ADDRESS" => "127.0.0.1:#{port}"}
      pid = Process.spawn(env, *Support.child_argv, [:out, :err] => File::NULL)

      begin
        client = Neovim.attach_tcp("127.0.0.1", port)
      rescue Errno::ECONNREFUSED
        retry
      end

      begin
        expect(client.strwidth("hi")).to eq(2)
      ensure
        Support.kill(pid)
        Process.waitpid(pid)
      end
    end
  end

  describe ".attach_unix" do
    before do
      skip("Not supported on this platform") if Support.windows?
    end

    it "attaches to a UNIX socket" do
      socket_path = Support.socket_path
      env = {"NVIM_LISTEN_ADDRESS" => socket_path}
      pid = Process.spawn(env, *Support.child_argv, [:out, :err] => File::NULL)

      begin
        client = Neovim.attach_unix(socket_path)
      rescue Errno::ENOENT, Errno::ECONNREFUSED
        retry
      end

      begin
        expect(client.strwidth("hi")).to eq(2)
      ensure
        Support.kill(pid)
        Process.waitpid(pid)
      end
    end
  end

  describe ".attach_child" do
    it "spawns and attaches to a child process" do
      begin
        client = Neovim.attach_child(Support.child_argv)
        expect(client.strwidth("hi")).to eq(2)
      ensure
        client.shutdown
      end
    end
  end

  describe ".executable" do
    it "returns the current executable" do
      expect(Neovim.executable).to be_a(Neovim::Executable)
    end
  end
end
