require "helper"
require "fileutils"

RSpec.describe Neovim do
  let(:nvim_executable) { ENV.fetch("NVIM_EXECUTABLE") }

  describe ".attach_tcp" do
    it "attaches to a TCP socket" do
      env = {"NVIM_LISTEN_ADDRESS" => "0.0.0.0:3333"}
      pid = Process.spawn(env, "#{nvim_executable} -u NONE -i NONE -N -n", :out => "/dev/null")

      begin
        wait_socket = TCPSocket.open("0.0.0.0", 3333)
      rescue Errno::ECONNREFUSED
        retry
      end
      wait_socket.close

      begin
        expect(Neovim.attach_tcp("0.0.0.0", 3333).strwidth("hi")).to eq(2)
      ensure
        Process.kill(:TERM, pid)
      end
    end
  end

  describe ".attach_unix" do
    it "attaches to a UNIX socket" do
      FileUtils.rm_f("/tmp/nvim.sock")
      env = {"NVIM_LISTEN_ADDRESS" => "/tmp/nvim.sock"}
      pid = Process.spawn(env, "#{nvim_executable} -u NONE -i NONE -N -n", :out => "/dev/null")

      loop { break if File.exists?("/tmp/nvim.sock") }

      begin
        expect(Neovim.attach_unix("/tmp/nvim.sock").strwidth("hi")).to eq(2)
      ensure
        Process.kill(:TERM, pid)
      end
    end
  end

  describe "attach_child" do
    it "spawns and attaches to a child process" do
      nvim = Neovim.attach_child(["-n", "-u", "NONE"])
      expect(nvim.strwidth("hi")).to eq(2)
    end
  end
end
