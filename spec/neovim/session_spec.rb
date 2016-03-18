require "helper"
require "securerandom"
require "fileutils"

module Neovim
  RSpec.describe Session do
    shared_context "session behavior" do
      it "supports requests" do
        expect(session.request(:vim_strwidth, "foobar")).to be(6)
      end

      it "supports notifications" do
        expect(session.notify(:vim_input, "jk")).to be(nil)
      end

      it "raises an exception when there are errors" do
        expect {
          session.request(:vim_strwidth, "too", "many")
        }.to raise_error(/wrong number of arguments/i)
      end

      it "handles large data" do
        large_str = Array.new(1024 * 16) { SecureRandom.hex(1) }.join
        session.request(:vim_set_current_line, large_str)
        expect(session.request(:vim_get_current_line)).to eq(large_str)
      end

      it "subscribes to events" do
        session.request(:vim_subscribe, "my_event")
        session.request(:vim_command, "call rpcnotify(0, 'my_event', 'foo')")

        messages = []
        session.run do |msg|
          messages << msg
          session.stop
        end

        expect(messages.first).to be_a(Notification)
        expect(messages.first.method_name).to eq("my_event")
        expect(messages.first.arguments).to eq(["foo"])
      end
    end

    context "tcp" do
      let!(:nvim_port) { Support.port }
      let!(:nvim_pid) do
        pid = Process.spawn(
          {"NVIM_LISTEN_ADDRESS" => "0.0.0.0:#{nvim_port}"},
          "#{ENV.fetch("NVIM_EXECUTABLE")} --headless -n -u NONE",
          [:out, :err] => "/dev/null"
        )

        begin
          TCPSocket.open("0.0.0.0", nvim_port).close
        rescue Errno::ECONNREFUSED
          retry
        end

        pid
      end

      after do
        Process.kill(:TERM, nvim_pid)
        Process.waitpid(nvim_pid)
      end

      let(:session) do
        event_loop = EventLoop.tcp("0.0.0.0", nvim_port)
        stream = MsgpackStream.new(event_loop)
        async = AsyncSession.new(stream)
        Session.new(async)
      end

      include_context "session behavior"
    end

    context "unix" do
      let!(:socket_path) { Support.socket_path }
      let!(:nvim_pid) do
        pid = Process.spawn(
          {"NVIM_LISTEN_ADDRESS" => socket_path},
          "#{ENV.fetch("NVIM_EXECUTABLE")} --headless -n -u NONE",
          [:out, :err] => "/dev/null"
        )

        begin
          UNIXSocket.new(socket_path).close
        rescue Errno::ENOENT, Errno::ECONNREFUSED
          retry
        end

        pid
      end

      after do
        Process.kill(:TERM, nvim_pid)
        Process.waitpid(nvim_pid)
      end

      let(:session) do
        event_loop = EventLoop.unix(socket_path)
        stream = MsgpackStream.new(event_loop)
        async = AsyncSession.new(stream)
        Session.new(async)
      end

      include_context "session behavior"
    end

    context "child" do
      let(:session) do
        event_loop = EventLoop.child(["-n", "-u", "NONE"])
        stream = MsgpackStream.new(event_loop)
        async = AsyncSession.new(stream)
        Session.new(async)
      end

      include_context "session behavior"
    end
  end
end
