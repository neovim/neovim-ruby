require "helper"
require "socket"
require "fileutils"

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
        Process.kill(:TERM, pid)
        Process.waitpid(pid, Process::WNOHANG)
      end
    end

    it "connects to a UNIX socket as a Pathname" do
      env = {"NVIM_LISTEN_ADDRESS" => "/tmp/nvim.sock"}
      pid = spawn(env, bin, [:out, :err] => "/dev/null")

      begin
        loop { break if File.exists?("/tmp/nvim.sock") }

        target = Pathname.new("/tmp/nvim.sock")
        client = Neovim.connect(target)
        expect(client.strwidth("hi")).to eq(2)
      ensure
        Process.kill(:TERM, pid)
        Process.waitpid(pid, Process::WNOHANG)
      end
    end

    it "connects to a TCP socket" do
      env = {"NVIM_LISTEN_ADDRESS" => "127.0.0.1:12321"}
      pid = spawn(env, bin, [:out, :err] => "/dev/null")

      begin
        wait_socket = TCPSocket.open("127.0.0.1", 12321)
      rescue Errno::ECONNREFUSED
        retry
      end
      wait_socket.close

      begin
        client = Neovim.connect("127.0.0.1:12321")
        expect(client.strwidth("hi")).to eq(2)
      ensure
        Process.kill(:TERM, pid)
        Process.waitpid(pid, Process::WNOHANG)
      end
    end

    it "connects to an embedded process through standard streams" do
      IO.popen("#{bin} --embed", "r+b", :err => "/dev/null") do |io|
        pid = io.pid

        begin
          client = Neovim.connect(io)
          expect(client.strwidth("hi")).to eq(2)
        ensure
          Process.kill(:TERM, pid)
          Process.waitpid(pid, Process::WNOHANG)
        end
      end
    end

    it "raises an exception otherwise" do
      expect {
        client = Neovim.connect("foobar")
      }.to raise_error(Neovim::InvalidAddress, /No such file or directory/)

      expect {
        client = Neovim.connect("127.0.0.1:80")
      }.to raise_error(Neovim::InvalidAddress, /Connection refused/)

      expect {
        client = Neovim.connect({})
      }.to raise_error(Neovim::InvalidAddress, /Can't connect to object/)
    end
  end
end
