require "helper"

module Neovim
  RSpec.describe EventLoop do
    let!(:push_pipe) { IO.pipe }
    let!(:pull_pipe) { IO.pipe }

    let(:client_rd) { push_pipe[0] }
    let(:client_wr) { pull_pipe[1] }
    let(:server_rd) { pull_pipe[0] }
    let(:server_wr) { push_pipe[1] }

    let(:connection) { Connection.new(client_rd, client_wr) }
    let(:event_loop) { EventLoop.new(connection) }

    describe "#request" do
      it "writes a msgpack request" do
        event_loop.request(1, :method, 1, 2)
        connection.flush
        message = server_rd.readpartial(1024)

        expect(message).to eq(MessagePack.pack([0, 1, "method", [1, 2]]))
      end
    end

    describe "#respond" do
      it "writes a msgpack response" do
        event_loop.respond(2, "value", "error")
        connection.flush
        message = server_rd.readpartial(1024)

        expect(message).to eq(MessagePack.pack([1, 2, "error", "value"]))
      end
    end

    describe "#notify" do
      it "writes a msgpack notification" do
        event_loop.notify(:method, 1, 2)
        connection.flush
        message = server_rd.readpartial(1024)

        expect(message).to eq(MessagePack.pack([2, "method", [1, 2]]))
      end
    end

    describe "#run" do
      it "yields received messages to the block" do
        server_wr.write(MessagePack.pack([0, 1, :foo_method, []]))
        server_wr.flush

        message = nil
        event_loop.run do |req|
          message = req
          event_loop.stop
        end

        expect(message.sync?).to eq(true)
        expect(message.method_name).to eq("foo_method")
      end

      it "returns the last message received" do
        server_wr.write(MessagePack.pack([0, 1, :foo_method, []]))
        server_wr.flush

        message = event_loop.run { |req| event_loop.stop; req }

        expect(message.sync?).to eq(true)
        expect(message.method_name).to eq("foo_method")
      end

      it "shuts down after receiving EOFError" do
        run_thread = Thread.new do
          event_loop.run
        end

        server_wr.close
        run_thread.join
        expect(client_rd).to be_closed
        expect(client_wr).to be_closed
      end
    end
  end
end
