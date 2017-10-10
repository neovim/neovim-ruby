require "helper"
require "neovim/event_loop"

module Neovim
  RSpec.describe EventLoop do
    let!(:push_pipe) { IO.pipe }
    let!(:pull_pipe) { IO.pipe }

    let(:client_rd) { push_pipe[0] }
    let(:client_wr) { pull_pipe[1] }
    let(:server_rd) { pull_pipe[0] }
    let(:server_wr) { push_pipe[1] }

    let(:connection) { EventLoop::Connection.new(client_rd, client_wr) }
    let(:event_loop) { EventLoop.new(connection) }

    describe "#run" do
      it "reads requests" do
        server_wr.write(MessagePack.pack([0, 1, :foo_method, []]))
        server_wr.flush

        request = nil
        event_loop.run do |req|
          request = req
          event_loop.stop
        end
        expect(request.method_name).to eq("foo_method")
      end

      it "writes requests" do
        response = nil

        event_loop.request(:foo_method) do |res|
          response = res
          event_loop.stop
        end

        server_wr.write(MessagePack.pack([1, 1, nil, :value]))
        server_wr.flush

        event_loop.run
        expect(response.value).to eq("value")
      end

      it "writes responses" do
        event_loop.respond(1, :foo_response, nil)

        server_wr.write(MessagePack.pack([2, :noop, []]))
        server_wr.flush

        event_loop.run { event_loop.stop }
        expect(server_rd.readpartial(1024)).to eq(
          MessagePack.pack([1, 1, nil, :foo_response])
        )
      end

      it "reads notifications" do
        server_wr.write(MessagePack.pack([2, :foo_notification, []]))
        server_wr.flush

        notification = nil
        event_loop.run do |ntf|
          notification = ntf
          event_loop.stop
        end
        expect(notification.method_name).to eq("foo_notification")
      end

      it "writes notifications" do
        event_loop.notify(:foo_notification)

        server_wr.write(MessagePack.pack([2, :noop, []]))
        server_wr.flush

        event_loop.run { event_loop.stop }
        expect(server_rd.readpartial(1024)).to eq(
          MessagePack.pack([2, :foo_notification, []])
        )
      end
    end
  end
end
