require "helper"
require "securerandom"

module Neovim
  RSpec.describe Session do
    shared_context "session behavior" do
      describe "#channel_id" do
        it "returns nil when the API hasn't been discovered" do
          expect(session.channel_id).to be(nil)
        end

        it "returns the channel_id when the API has been discovered" do
          session.discover_api
          expect(session.channel_id).to respond_to(:to_int)
        end
      end

      describe "#request" do
        it "synchronously returns a result" do
          expect(session.request(:nvim_strwidth, "foobar")).to be(6)
        end

        it "raises an exception when there are errors" do
          expect {
            session.request(:nvim_strwidth, "too", "many")
          }.to raise_error(/wrong number of arguments/i)
        end

        it "handles large data" do
          large_str = Array.new(1024 * 17) { SecureRandom.hex(1) }.join
          session.request(:nvim_set_current_line, large_str)
          expect(session.request(:nvim_get_current_line)).to eq(large_str)
        end

        it "fails outside of the main thread" do
          expect {
            Thread.new { session.request(:nvim_strwidth, "foo") }.join
          }.to raise_error(/outside of the main thread/)
        end
      end

      describe "#notify" do
        it "returns nil" do
          expect(session.notify(:nvim_input, "jk")).to be(nil)
        end

        it "doesn't raise exceptions" do
          expect {
            session.notify(:nvim_strwidth, "too", "many")
          }.not_to raise_error
        end

        it "handles large data" do
          large_str = Array.new(1024 * 17) { SecureRandom.hex(1) }.join
          session.notify(:nvim_set_current_line, large_str)
          expect(session.request(:nvim_get_current_line)).to eq(large_str)
        end

        it "fails outside of the main thread" do
          expect {
            Thread.new { session.notify(:nvim_set_current_line, "foo") }.join
          }.to raise_error(/outside of the main thread/)
        end
      end

      describe "#run" do
        it "enqueues messages received during blocking requests" do
          session.request(:nvim_subscribe, "my_event")
          session.request(:nvim_command, "call rpcnotify(0, 'my_event', 'foo')")

          message = nil
          session.run do |msg|
            message = msg
            session.shutdown
          end

          expect(message).to be_a(Session::Notification)
          expect(message.method_name).to eq("my_event")
          expect(message.arguments).to eq(["foo"])
        end

        it "supports requests within callbacks" do
          session.request(:nvim_subscribe, "my_event")
          session.request(:nvim_command, "call rpcnotify(0, 'my_event', 'foo')")

          result = nil
          session.run do |msg|
            result = session.request(:nvim_strwidth, msg.arguments.first)
            session.shutdown
          end

          expect(result).to be(3)
        end
      end
    end

    context "tcp" do
      let!(:nvim_port) { Support.tcp_port }
      let!(:nvim_pid) do
        pid = Process.spawn(
          {"NVIM_LISTEN_ADDRESS" => "0.0.0.0:#{nvim_port}"},
          Support.child_argv.join(" "),
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

      let!(:session) { Session.tcp("0.0.0.0", nvim_port) }
      include_context "session behavior"
    end

    context "unix" do
      let!(:socket_path) { Support.socket_path }
      let!(:nvim_pid) do
        pid = Process.spawn(
          {"NVIM_LISTEN_ADDRESS" => socket_path},
          Support.child_argv.join(" "),
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

      let!(:session) { Session.unix(socket_path) }
      include_context "session behavior"
    end

    context "child" do
      let!(:session) { Session.child(Support.child_argv) }
      include_context "session behavior"
      after { session.shutdown }
    end
  end
end
