require "helper"

module Neovim
  RSpec.describe Session do
    let(:event_loop) { EventLoop.child(Support.child_argv) }
    let!(:session) { Session.new(event_loop) }

    after { session.shutdown }

    describe "#request" do
      it "synchronously returns a result" do
        expect(session.request(:nvim_strwidth, "foobar")).to be(6)
      end

      it "raises an exception when there are errors" do
        expect do
          session.request(:nvim_strwidth, "too", "many")
        end.to raise_error(/wrong number of arguments/i)
      end

      it "handles large data" do
        large_str = Array.new(1024 * 17) { SecureRandom.hex(1) }.join
        session.request(:nvim_set_current_line, large_str)
        expect(session.request(:nvim_get_current_line)).to eq(large_str)
      end

      it "raises an exception when a command causes nvim to exit" do
        expect do
          session.request(:nvim_command, "qa!")
        end.to raise_error(Neovim::Session::Exited, /exited/)
      end

      it "fails outside of the main thread", :silence_thread_exceptions do
        expect do
          Thread.new { session.request(:nvim_strwidth, "foo") }.join
        end.to raise_error(/outside of the main thread/)
      end
    end

    describe "#notify" do
      it "handles large data" do
        large_str = Array.new(1024 * 17) { SecureRandom.hex(1) }.join
        session.notify(:nvim_set_current_line, large_str)
        expect(session.request(:nvim_get_current_line)).to eq(large_str)
      end

      it "succeeds outside of the main thread" do
        expect do
          Thread.new { session.notify(:nvim_set_current_line, "foo") }.join
        end.not_to raise_error
      end
    end

    describe "#next" do
      it "returns the next message from the event loop" do
        cid, = session.request(:nvim_get_api_info)
        session.request(:nvim_command, "call rpcnotify(#{cid}, 'my_event', 'foo')")

        message = session.next

        expect(message.sync?).to eq(false)
        expect(message.method_name).to eq("my_event")
        expect(message.arguments).to eq(["foo"])
      end

      it "returns asynchronous notification errors" do
        session.notify(:nvim_set_current_line, "too", "many", "args")

        message = session.next

        expect(message.sync?).to eq(false)
        expect(message.method_name).to eq("nvim_error_event")
        expect(message.arguments).to eq([0, "Wrong number of arguments: expecting 1 but got 3"])
      end
    end
  end
end
