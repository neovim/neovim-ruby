require "helper"
require "socket"
require "msgpack"
require "fileutils"

module Neovim
  RSpec.describe EventLoop do
    shared_context "socket behaviors" do
      it "sends and receives data" do
        messages = []

        srv_thr = Thread.new do
          client = server.accept
          messages << client.readpartial(1024)

          client.write("OK")
          client.close
          server.close
        end

        event_loop.send("data").run do |msg|
          expect(msg).to eq("OK")
          event_loop.stop
        end

        srv_thr.join
        expect(messages).to eq(["data"])
      end
    end

    context "tcp" do
      let!(:server) { TCPServer.new("0.0.0.0", 0) }
      let!(:event_loop) { EventLoop.tcp("0.0.0.0", server.addr[1]) }

      include_context "socket behaviors"
    end

    context "unix" do
      before { FileUtils.rm_f("/tmp/#$$.sock") }
      after { FileUtils.rm_f("/tmp/#$$.sock") }
      let!(:server) { UNIXServer.new("/tmp/#$$.sock") }
      let!(:event_loop) { EventLoop.unix("/tmp/#$$.sock") }

      include_context "socket behaviors"
    end

    context "child" do
      it "sends and receives data" do
        event_loop = EventLoop.child(["-n", "-u", "NONE"])
        message = MessagePack.pack([0, 0, :vim_strwidth, ["hi"]])

        event_loop.send(message).run do |msg|
          expect(msg).to eq(MessagePack.pack([1, 0, nil, 2]))
          event_loop.stop
        end
      end
    end
  end
end
