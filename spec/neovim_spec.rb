require "helper"
require "fileutils"

RSpec.describe Neovim do
  let(:nvim_executable) { ENV.fetch("NVIM_EXECUTABLE") }

  describe ".attach_tcp" do
    it "attaches to a TCP socket" do
      srv = TCPServer.new("0.0.0.0", 0)
      port = srv.addr[1]
      srv.close

      env = {"NVIM_LISTEN_ADDRESS" => "0.0.0.0:#{port}"}
      pid = Process.spawn(env, "#{nvim_executable} -u NONE -i NONE -N -n", :out => "/dev/null")

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
      FileUtils.rm_f("/tmp/#$$.sock")
      env = {"NVIM_LISTEN_ADDRESS" => "/tmp/#$$.sock"}
      pid = Process.spawn(env, "#{nvim_executable} -u NONE -i NONE -N -n", :out => "/dev/null")

      loop { break if File.exists?("/tmp/#$$.sock") }

      begin
        expect(Neovim.attach_unix("/tmp/#$$.sock").strwidth("hi")).to eq(2)
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
