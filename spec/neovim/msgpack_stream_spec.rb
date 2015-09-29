require "socket"
require "helper"

module Neovim
  RSpec.describe MsgpackStream do
    it "sends and receives msgpack" do
      server = TCPServer.new("0.0.0.0", 3333)
      event_loop = EventLoop.tcp("0.0.0.0", 3333)
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
        stream.shutdown
      end

      expect(messages).to eq([MessagePack.pack([1])])
    end
  end
end
