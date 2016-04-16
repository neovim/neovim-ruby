require "socket"
require "helper"

module Neovim
  RSpec.describe MsgpackStream do
    shared_context "msgpack stream behavior" do
      it "sends and receives data" do
        msgpack_stream = MsgpackStream.new(event_loop)
        request = nil

        server_thread = Thread.new do
          client = server.accept
          request = client.readpartial(1024)

          client.write(MessagePack.pack(["res"]))
          client.close
          server.close
        end

        response = nil
        msgpack_stream.write(["req"]).run do |message|
          response = message
          msgpack_stream.shutdown
        end

        server_thread.join
        expect(request).to eq(MessagePack.pack(["req"]))
        expect(response).to eq(["res"])
      end
    end

    context "tcp" do
      let!(:server) { TCPServer.new("0.0.0.0", 0) }
      let!(:event_loop) { EventLoop.tcp("0.0.0.0", server.addr[1]) }

      include_context "msgpack stream behavior"
    end

    context "unix" do
      let!(:server) { UNIXServer.new(Support.socket_path) }
      let!(:event_loop) { EventLoop.unix(Support.socket_path) }

      include_context "msgpack stream behavior"
    end
  end
end
