require "helper"

RSpec.describe Neovim do
  describe ".connect" do
    let(:bin) { File.expand_path("../../vendor/neovim/build/bin/nvim", __FILE__) }

    it "connects to a UNIX socket" do
      env = {"NVIM_LISTEN_ADDRESS" => "/tmp/nvim.sock"}
      pid = spawn(env, bin, [:out, :err] => "/dev/null")

      begin
        loop { break if File.exists?("/tmp/nvim.sock") }

        client = Neovim.connect("/tmp/nvim.sock")
        expect(client.strwidth("hi")).to eq(2)
      ensure
        Process.kill(:KILL, pid)
        Process.waitpid(pid)
        File.delete("/tmp/nvim.sock")
      end
    end

    it "connects to a TCP socket" do
      env = {"NVIM_LISTEN_ADDRESS" => "127.0.0.1:6666"}
      pid = spawn(env, bin, [:out, :err] => "/dev/null")
      wait_socket = TCPSocket.open("127.0.0.1", 6666)

      begin
        IO.select(nil, [wait_socket], nil, 1)

        client = Neovim.connect("127.0.0.1", 6666)
        expect(client.strwidth("hi")).to eq(2)
      ensure
        wait_socket.close
        Process.kill(:KILL, pid)
        Process.waitpid(pid)
      end
    end

    it "raises an exception otherwise" do
      expect {
        client = Neovim.connect("foobar")
      }.to raise_error(Neovim::InvalidAddress, /No such file or directory/)

      expect {
        client = Neovim.connect("127.0.0.1", 6667)
      }.to raise_error(Neovim::InvalidAddress, /Connection refused/)
    end
  end
end
