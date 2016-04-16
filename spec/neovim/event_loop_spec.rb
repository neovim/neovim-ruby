require "helper"
require "socket"

module Neovim
  RSpec.describe EventLoop do
    shared_context "socket behavior" do
      it "sends and receives data" do
        request = nil

        server_thread = Thread.new do
          client = server.accept
          request = client.readpartial(1024)

          client.write("res")
          client.close
          server.close
        end

        response = nil
        event_loop.write("req").run do |msg|
          response = msg
          event_loop.stop
        end

        server_thread.join
        event_loop.shutdown
        expect(request).to eq("req")
        expect(response).to eq("res")
      end
    end

    context "tcp" do
      let!(:server) { TCPServer.new("0.0.0.0", 0) }
      let!(:event_loop) { EventLoop.tcp("0.0.0.0", server.addr[1]) }

      include_context "socket behavior"
    end

    context "unix" do
      let!(:server) { UNIXServer.new(Support.socket_path) }
      let!(:event_loop) { EventLoop.unix(Support.socket_path) }

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
          request = nil

          server_thread = Thread.new do
            request = srv_stdout.readpartial(1024)
            srv_stdin.write("res")
          end

          response = nil
          event_loop.write("req").run do |msg|
            response = msg
            event_loop.stop
          end

          server_thread.join
          expect(request).to eq("req")
          expect(response).to eq("res")
        ensure
          STDOUT.reopen(old_stdout)
          STDIN.reopen(old_stdin)
        end
      end
    end

    context "child" do
      it "sends and receives data" do
        event_loop = EventLoop.child(["nvim", "-n", "-u", "NONE"])
        input = MessagePack.pack([0, 0, :vim_strwidth, ["hi"]])

        response = nil
        event_loop.write(input).run do |msg|
          response = msg
          event_loop.stop
        end

        event_loop.shutdown
        expect(response).to eq(MessagePack.pack([1, 0, nil, 2]))
      end
    end
  end
end
