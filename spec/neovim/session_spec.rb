require "helper"

module Neovim
  RSpec.describe Session do
    let(:client) { Support.persistent_client }
    let(:session) { client.session }

    describe "#request" do
      it "synchronously returns a result" do
        expect(session.request(:nvim_strwidth, "foobar")).to be(6)
      end

      it "raises an exception when there are errors" do
        expect do
          session.request(:nvim_strwidth, "too", "many")
        end.to raise_error(/wrong number of arguments/i)
      end

      it "fails outside of the main thread", :silence_thread_exceptions do
        expect do
          Thread.new { session.request(:nvim_strwidth, "foo") }.join
        end.to raise_error(/outside of the main thread/)
      end
    end

    describe "#notify" do
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

      it "returns asynchronous notification errors", nvim_version: ">= 0.4.pre.dev" do
        session.notify(:nvim_set_current_line, "too", "many", "args")

        message = session.next

        expect(message.sync?).to eq(false)
        expect(message.method_name).to eq("nvim_error_event")
        expect(message.arguments).to eq([0, "Wrong number of arguments: expecting 1 but got 3"])
      end
    end
  end
end
