require "helper"
require "socket"
require "msgpack"
require "fileutils"

module Neovim
  RSpec.describe EventLoop do
    shared_context "socket behavior" do
      it "sends and receives data" do
        messages = []

        srv_thr = Thread.new do
          client = server.accept
          messages << client.readpartial(1024)

          client.write("OK")
        end

        fiber = Fiber.new do
          event_loop.send("data").run do |msg|
            Fiber.yield(msg)
          end
        end

        expect(fiber.resume).to eq("OK")
        srv_thr.join
        expect(messages).to eq(["data"])
      end
    end

    context "tcp" do
      let!(:server) { TCPServer.new("0.0.0.0", 0) }
      let!(:event_loop) { EventLoop.tcp("0.0.0.0", server.addr[1]) }

      include_context "socket behavior"
    end

    context "unix" do
      before { FileUtils.rm_f("/tmp/#$$.sock") }
      after { FileUtils.rm_f("/tmp/#$$.sock") }
      let!(:server) { UNIXServer.new("/tmp/#$$.sock") }
      let!(:event_loop) { EventLoop.unix("/tmp/#$$.sock") }

      include_context "socket behavior"
    end

    context "child" do
      it "sends and receives data" do
        event_loop = EventLoop.child(["-n", "-u", "NONE"])
        message = MessagePack.pack([0, 0, :vim_strwidth, ["hi"]])

        fiber = Fiber.new do
          event_loop.send(message).run do |msg|
            Fiber.yield(msg)
          end
        end

        expect(fiber.resume).to eq(MessagePack.pack([1, 0, nil, 2]))
      end
    end
  end
end
