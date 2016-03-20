require "helper"

module Neovim
  RSpec.describe AsyncSession do
    shared_context "async session behavior" do
      it "receives requests" do
        stream = MsgpackStream.new(event_loop)
        async_session = AsyncSession.new(stream)

        server_thread = Thread.new do
          client = server.accept
          IO.select(nil, [client])
          client.write(MessagePack.pack(
            [0, 123, "func", [1, 2, 3]]
          ))
        end

        request = nil
        async_session.run do |msg|
          request = msg
          async_session.shutdown
        end

        server_thread.join

        expect(request).to be_a(Request)
        expect(request.method_name).to eq("func")
        expect(request.arguments).to eq([1, 2, 3])
      end

      it "receives notifications" do
        stream = MsgpackStream.new(event_loop)
        async_session = AsyncSession.new(stream)

        server_thread = Thread.new do
          client = server.accept
          IO.select(nil, [client])
          client.write(MessagePack.pack(
            [2, "func", [1, 2, 3]]
          ))
        end

        notification = nil
        async_session.run do |message|
          notification = message
          async_session.shutdown
        end

        server_thread.join

        expect(notification).to be_a(Notification)
        expect(notification.method_name).to eq("func")
        expect(notification.arguments).to eq([1, 2, 3])
      end

      it "receives responses to requests" do
        stream = MsgpackStream.new(event_loop)
        async_session = AsyncSession.new(stream)
        messages = []

        server_thread = Thread.new do
          client = server.accept
          messages << client.readpartial(1024)

          client.write(MessagePack.pack(
            [1, 0, [0, "error"], "result"]
          ))
        end

        error, result = nil
        async_session.request("func", 1, 2, 3) do |err, res|
          error, result = err, res
          async_session.shutdown
        end.run

        expect(error).to eq("error")
        expect(result).to eq("result")

        server_thread.join
        async_session.shutdown

        expect(messages).to eq(
          [MessagePack.pack([0, 0, "func", [1, 2, 3]])]
        )
      end
    end

    context "tcp" do
      let!(:server) { TCPServer.new("0.0.0.0", 0) }
      let!(:event_loop) { EventLoop.tcp("0.0.0.0", server.addr[1]) }

      include_context "async session behavior"
    end

    context "unix" do
      let!(:server) { UNIXServer.new(Support.socket_path) }
      let!(:event_loop) { EventLoop.unix(Support.socket_path) }

      include_context "async session behavior"
    end
  end
end
