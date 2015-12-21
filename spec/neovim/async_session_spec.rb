require "helper"

module Neovim
  RSpec.describe AsyncSession do
    shared_context "async session behavior" do
      it "receives requests" do
        stream = MsgpackStream.new(event_loop)
        async = AsyncSession.new(stream)

        srv_thr = Thread.new do
          client = server.accept
          IO.select(nil, [client])
          client.write(MessagePack.pack(
            [0, 123, "func", [1, 2, 3]]
          ))
        end

        req_cb = Proc.new do |request|
          Fiber.yield(request)
        end

        fiber = Fiber.new do
          async.run(req_cb)
        end

        request = fiber.resume

        srv_thr.join

        expect(request).to be_a(Request)
        expect(request.method_name).to eq("func")
        expect(request.arguments).to eq([1, 2, 3])
      end

      it "receives notifications" do
        stream = MsgpackStream.new(event_loop)
        async = AsyncSession.new(stream)

        srv_thr = Thread.new do
          client = server.accept
          IO.select(nil, [client])
          client.write(MessagePack.pack(
            [2, "func", [1, 2, 3]]
          ))
        end

        not_cb = Proc.new do |notification|
          Fiber.yield(notification)
        end

        fiber = Fiber.new do
          async.run(nil, not_cb)
        end

        notification = fiber.resume

        srv_thr.join

        expect(notification).to be_a(Notification)
        expect(notification.method_name).to eq("func")
        expect(notification.arguments).to eq([1, 2, 3])
      end

      it "receives responses to requests" do
        stream = MsgpackStream.new(event_loop)
        async = AsyncSession.new(stream)
        messages = []

        srv_thr = Thread.new do
          client = server.accept
          messages << client.readpartial(1024)

          client.write(MessagePack.pack(
            [1, 0, [0, "error"], "result"]
          ))
        end

        fiber = Fiber.new do
          async.request("func", 1, 2, 3) do |error, result|
            Fiber.yield(error, result)
          end.run
        end

        expect(fiber.resume).to eq(["error", "result"])

        srv_thr.join

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
      before { FileUtils.rm_f("/tmp/#$$.sock") }
      after { FileUtils.rm_f("/tmp/#$$.sock") }
      let!(:server) { UNIXServer.new("/tmp/#$$.sock") }
      let!(:event_loop) { EventLoop.unix("/tmp/#$$.sock") }

      include_context "async session behavior"
    end
  end
end
