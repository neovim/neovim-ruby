require "socket"
require "helper"

module Neovim
  RSpec.describe MsgpackStream do
    shared_context "msgpack stream behavior" do
      it "sends and receives data" do
        stream = MsgpackStream.new(event_loop)
        messages = []

        srv_thr = Thread.new do
          client = server.accept
          messages << client.read_nonblock(1024)

          client.write(MessagePack.pack([2]))
          client.close
          server.close
        end

        stream.send([1]).run do |msg|
          expect(msg).to eq([2])
          stream.stop
        end

        expect(messages).to eq([MessagePack.pack([1])])
      end
    end

    context "tcp" do
      let!(:server) { TCPServer.new("0.0.0.0", 0) }
      let!(:event_loop) { EventLoop.tcp("0.0.0.0", server.addr[1]) }

      include_context "msgpack stream behavior"
    end

    context "unix" do
      before { FileUtils.rm_f("/tmp/#$$.sock") }
      after { FileUtils.rm_f("/tmp/#$$.sock") }
      let!(:server) { UNIXServer.new("/tmp/#$$.sock") }
      let!(:event_loop) { EventLoop.unix("/tmp/#$$.sock") }

      include_context "msgpack stream behavior"
    end
  end
end
