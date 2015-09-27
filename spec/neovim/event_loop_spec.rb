require "helper"
require "socket"

module Neovim
  RSpec.describe EventLoop do
    before do
      File.delete("/tmp/#$$.sock") if File.exists?("/tmp/#$$.sock")
    end

    shared_context "sending and receiving data" do
      it "sends and receives data" do
        messages = []

        srv_thr = Thread.new do
          client = server.accept
          messages << client.readpartial(1024)

          client.write("from server")
          client.close
          server.close
        end

        event_loop.send("data").run do |msg|
          expect(msg).to eq("from server")
          event_loop.stop
        end

        srv_thr.join
        expect(messages).to eq(["data"])
      end
    end

    context "TCP" do
      let!(:server) { TCPServer.new(3333) }
      let!(:event_loop) { EventLoop.tcp("0.0.0.0", 3333) }

      include_context "sending and receiving data"
    end

    context "Unix" do
      let!(:server) { UNIXServer.new("/tmp/#$$.sock") }
      let!(:event_loop) { EventLoop.unix("/tmp/#$$.sock") }

      include_context "sending and receiving data"
    end
  end
end
