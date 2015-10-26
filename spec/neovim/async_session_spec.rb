require "helper"

module Neovim
  RSpec.describe AsyncSession do
    it "receives requests" do
      server = TCPServer.new("0.0.0.0", 0)
      event_loop = EventLoop.tcp("0.0.0.0", server.addr[1])
      stream = MsgpackStream.new(event_loop)
      async = AsyncSession.new(stream)
      requests = []

      srv_thr = Thread.new do
        client = server.accept
        client.write(MessagePack.pack(
          [0, 123, "func", [1, 2, 3]]
        ))

        client.close
        server.close
      end

      req_cb = Proc.new do |request|
        requests << request
        async.shutdown
      end

      async.run(req_cb)
      srv_thr.join

      request = requests.first
      expect(request).to be_a(Request)
      expect(request.method_name).to eq("func")
      expect(request.arguments).to eq([1, 2, 3])
    end

    it "receives notifications" do
      server = TCPServer.new("0.0.0.0", 0)
      event_loop = EventLoop.tcp("0.0.0.0", server.addr[1])
      stream = MsgpackStream.new(event_loop)
      async = AsyncSession.new(stream)
      notifications = []

      srv_thr = Thread.new do
        client = server.accept
        client.write(MessagePack.pack(
          [2, "func", [1, 2, 3]]
        ))

        client.close
        server.close
      end

      not_cb = Proc.new do |notification|
        notifications << notification
        async.shutdown
      end

      async.run(nil, not_cb)
      srv_thr.join

      notification = notifications.first
      expect(notification).to be_a(Notification)
      expect(notification.method_name).to eq("func")
      expect(notification.arguments).to eq([1, 2, 3])
    end

    it "receives responses to requests" do
      server = TCPServer.new("0.0.0.0", 0)
      event_loop = EventLoop.tcp("0.0.0.0", server.addr[1])
      stream = MsgpackStream.new(event_loop)
      async = AsyncSession.new(stream)
      messages = []

      srv_thr = Thread.new do
        client = server.accept
        messages << client.read_nonblock(1024)

        client.write(MessagePack.pack(
          [1, 0, [0, "error"], "result"]
        ))

        client.close
        server.close
      end

      async.request("func", 1, 2, 3) do |error, result|
        expect(error).to eq("error")
        expect(result).to eq("result")
        async.shutdown
      end

      async.run
      srv_thr.join

      expect(messages).to eq(
        [MessagePack.pack([0, 0, "func", [1, 2, 3]])]
      )
    end
  end
end
