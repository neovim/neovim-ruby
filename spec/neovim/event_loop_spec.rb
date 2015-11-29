require "helper"
require "socket"
require "msgpack"
require "fileutils"

module Neovim
  RSpec.describe EventLoop do
    it "calls the setup callback" do
      messages = []
      rd, wr = IO.pipe
      event_loop = EventLoop.new(rd, wr)

      fiber = Fiber.new do
        setup_cb = Proc.new { Fiber.yield(:setup) }
        event_loop.run(nil, setup_cb)
      end

      expect(fiber.resume).to eq(:setup)
    end

    shared_context "socket behavior" do
      it "sends and receives data" do
        messages = []

        srv_thr = Thread.new do
          client = server.accept
          messages << client.readpartial(1024)

          client.write("OK")
          client.close
          server.close
        end

        fiber = Fiber.new do
          msg_cb = Proc.new { |msg| Fiber.yield(msg) }
          event_loop.send("data").run(msg_cb)
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

    context "stdio" do
      it "sends and receives data" do
        old_stdout = STDOUT.dup
        old_stdin = STDIN.dup

        begin
          srv_stdout, cl_stdout = IO.pipe
          cl_stdin, srv_stdin = IO.pipe

          STDOUT.reopen(cl_stdout)
          STDIN.reopen(cl_stdin)

          event_loop = EventLoop.stdio
          messages = []

          srv_thr = Thread.new do
            messages << srv_stdout.readpartial(1024)
            srv_stdin.write("OK")
          end

          fiber = Fiber.new do
            msg_cb = Proc.new { |msg| Fiber.yield(msg) }
            event_loop.send("data").run(msg_cb)
          end

          expect(fiber.resume).to eq("OK")
          srv_thr.join
          expect(messages).to eq(["data"])
        ensure
          STDOUT.reopen(old_stdout)
          STDIN.reopen(old_stdin)
        end
      end
    end

    context "child" do
      it "sends and receives data" do
        event_loop = EventLoop.child(["-n", "-u", "NONE"])
        message = MessagePack.pack([0, 0, :vim_strwidth, ["hi"]])

        fiber = Fiber.new do
          msg_cb = Proc.new { |msg| Fiber.yield(msg) }
          event_loop.send(message).run(msg_cb)
        end

        expect(fiber.resume).to eq(MessagePack.pack([1, 0, nil, 2]))
      end
    end
  end
end
