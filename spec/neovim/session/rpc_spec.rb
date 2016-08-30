require "helper"

module Neovim
  class Session
    RSpec.describe RPC do
      shared_context "rpc behavior" do
        it "receives requests" do
          serializer = Serializer.new(event_loop)
          rpc = RPC.new(serializer)

          server_thread = Thread.new do
            client = server.accept
            client.write(
              MessagePack.pack(
                [0, 123, "func", [1, 2, 3]]
              )
            )
          end

          request = nil
          rpc.run do |msg|
            request = msg
            rpc.shutdown
          end

          server_thread.join

          expect(request).to be_a(Request)
          expect(request.method_name).to eq("func")
          expect(request.arguments).to eq([1, 2, 3])
        end

        it "receives notifications" do
          serializer = Serializer.new(event_loop)
          rpc = RPC.new(serializer)

          server_thread = Thread.new do
            client = server.accept
            client.write(
              MessagePack.pack(
                [2, "func", [1, 2, 3]]
              )
            )
          end

          notification = nil
          rpc.run do |message|
            notification = message
            rpc.shutdown
          end

          server_thread.join

          expect(notification).to be_a(Notification)
          expect(notification.method_name).to eq("func")
          expect(notification.arguments).to eq([1, 2, 3])
        end

        it "receives responses to requests" do
          serializer = Serializer.new(event_loop)
          rpc = RPC.new(serializer)
          request = nil

          server_thread = Thread.new do
            client = server.accept
            request = client.readpartial(1024)

            client.write(
              MessagePack.pack(
                [1, 0, [0, "error"], "result"]
              )
            )
          end

          error, result = nil
          rpc.request("func", 1, 2, 3) do |err, res|
            error, result = err, res
            rpc.shutdown
          end.run

          expect(error).to eq("error")
          expect(result).to eq("result")

          server_thread.join
          rpc.shutdown

          expect(request).to eq(
            MessagePack.pack([0, 0, "func", [1, 2, 3]])
          )
        end
      end

      context "tcp" do
        let!(:server) { TCPServer.new("0.0.0.0", 0) }
        let!(:event_loop) { EventLoop.tcp("0.0.0.0", server.addr[1]) }

        include_context "rpc behavior"
      end

      context "unix" do
        let!(:server) { UNIXServer.new(Support.socket_path) }
        let!(:event_loop) { EventLoop.unix(Support.socket_path) }

        include_context "rpc behavior"
      end

      describe "#run" do
        it "logs exceptions" do
          serializer = instance_double(Serializer)
          rpc = RPC.new(serializer)

          expect(serializer).to receive(:run).and_raise("BOOM")
          expect(rpc).to receive(:fatal).with(/BOOM/)

          rpc.run
        end
      end
    end
  end
end
