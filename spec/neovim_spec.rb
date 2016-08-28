require "helper"

RSpec.describe Neovim do
  describe ".attach_tcp" do
    it "attaches to a TCP socket" do
      port = Support.tcp_port
      env = {"NVIM_LISTEN_ADDRESS" => "0.0.0.0:#{port}"}
      pid = Process.spawn(env, *Support.child_argv, [:out, :err] => "/dev/null")

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
      pid = Process.spawn(env, *Support.child_argv, [:out, :err] => "/dev/null")

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
        client = Neovim.attach_child(Support.child_argv)
        expect(client.strwidth("hi")).to eq(2)
      ensure
        client.shutdown
      end
    end
  end
end
