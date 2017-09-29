require "helper"
require "securerandom"

module Neovim
  RSpec.describe Session do
    let(:connection) { Session::Connection.child(Support.child_argv) }
    let(:event_loop) { Session::EventLoop.new(connection) }
    let!(:session) { Session.new(event_loop) }

    after { session.shutdown }

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

      it "succeeds outside of the main thread" do
        expect {
          Thread.new { session.notify(:nvim_set_current_line, "foo") }.join
        }.not_to raise_error
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

        expect(message.sync?).to eq(false)
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
end
