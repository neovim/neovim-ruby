require "helper"

module Neovim
  RSpec.describe AsyncSession do
    it "receives requests" do
      server = Server.unix("/tmp/#{$$}.sock")
      stream = MsgpackStream.new(server)
      async = AsyncSession.new(stream)
      messages = []

      req_cb = Proc.new do |*payload|
        messages << payload
        async.stop
      end

      thr = Thread.new do
        async.run(req_cb)
      end

      IO.popen(["/usr/bin/nc", "-U", "/tmp/#{$$}.sock"], "rb+") do |io|
        io.write(MessagePack.pack([0, 1, "func", [2]]))
        io.close_write
      end

      thr.join
      expect(messages.size).to eq(1)
      message = messages.first

      expect(message.size).to eq(3)
      expect(message[0..1]).to eq(["func", [2]])
      expect(message[2]).to be_a(AsyncSession::Response)
    end

    it "receives notifications" do
      server = Server.unix("/tmp/#{$$}.sock")
      stream = MsgpackStream.new(server)
      async = AsyncSession.new(stream)
      notifications = []

      not_cb = Proc.new do |*payload|
        notifications << payload
        async.stop
      end

      thr = Thread.new do
        async.run(nil, not_cb)
      end

      IO.popen(["/usr/bin/nc", "-U", "/tmp/#{$$}.sock"], "rb+") do |io|
        io.write(MessagePack.pack([2, "event", [2]]))
        io.close_write
      end

      thr.join
      expect(notifications).to eq([["event", [2]]])
    end

    it "receives responses" do
      server = Server.unix("/tmp/#{$$}.sock")
      stream = MsgpackStream.new(server)
      async = AsyncSession.new(stream)
      responses = []

      thr = Thread.new do
        async.run
      end

      async.request("func", 1, 2) do |*response|
        responses << response
        async.stop
      end

      IO.popen(["/usr/bin/nc", "-U", "/tmp/#{$$}.sock"], "rb+") do |io|
        io.write(MessagePack.pack([1, 0, "error", "result"]))
        io.close_write
      end

      thr.join
      expect(responses).to eq([["error", "result"]])
    end
  end
end
