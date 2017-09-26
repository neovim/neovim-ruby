require "helper"
require "socket"

module Neovim
  class Session
    RSpec.describe IO do
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
          io.write("req").run do |msg|
            response = msg
            io.stop
          end

          server_thread.join
          io.shutdown
          expect(request).to eq("req")
          expect(response).to eq("res")
        end
      end

      context "tcp" do
        let!(:server) { TCPServer.new("0.0.0.0", 0) }
        let!(:io) { IO.tcp("0.0.0.0", server.addr[1]) }

        include_context "socket behavior"
      end

      context "unix" do
        let!(:server) { UNIXServer.new(Support.socket_path) }
        let!(:io) { IO.unix(Support.socket_path) }

        include_context "socket behavior"
      end

      context "stdio" do
        it "sends and receives data" do
          old_stdout = STDOUT.dup
          old_stdin = STDIN.dup

          begin
            srv_stdout, cl_stdout = ::IO.pipe
            cl_stdin, srv_stdin = ::IO.pipe

            STDOUT.reopen(cl_stdout)
            STDIN.reopen(cl_stdin)

            io = IO.stdio
            request = nil

            server_thread = Thread.new do
              request = srv_stdout.readpartial(1024)
              srv_stdin.write("res")
            end

            response = nil
            io.write("req").run do |msg|
              response = msg
              io.stop
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
          io = IO.child(Support.child_argv)
          input = MessagePack.pack([0, 0, :nvim_strwidth, ["hi"]])

          response = nil
          io.write(input).run do |msg|
            response = msg
            io.shutdown
          end

          expect(response).to eq(MessagePack.pack([1, 0, nil, 2]))
        end
      end

      describe "#run" do
        it "handles EOF" do
          rd, wr = ::IO.pipe
          wr.close
          io = IO.new(rd, wr)
          expect(io).to receive(:info).with(/EOFError/)

          io.run
        end

        it "handles other errors" do
          rd, wr = ::IO.pipe
          rd.close
          io = IO.new(rd, wr)
          expect(io).to receive(:fatal).with(/IOError/)

          io.run
        end
      end

      describe "#write" do
        it "retries when writes would block" do
          rd, wr = ::IO.pipe
          io = IO.new(rd, wr)
          err_class = Class.new(RuntimeError) { include ::IO::WaitWritable }

          expect(wr).to receive(:write_nonblock).and_raise(err_class)
          expect(wr).to receive(:write_nonblock).and_call_original

          io.write("a")
          expect(rd.readpartial(1)).to eq("a")
        end
      end

      describe "#shutdown" do
        it "closes IO handles" do
          rd, wr = ::IO.pipe
          IO.new(rd, wr).shutdown

          expect(rd).to be_closed
          expect(wr).to be_closed
        end

        it "kills spawned processes" do
          io = ::IO.popen("cat", "rb+")
          pid = io.pid
          expect(pid).to respond_to(:to_int)

          IO.new(io).shutdown
          expect { Process.kill(0, pid) }.to raise_error(Errno::ESRCH)
        end
      end
    end
  end
end
