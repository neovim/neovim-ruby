require "helper"

module Neovim
  class EventLoop
    RSpec.describe Connection do
      let(:nil_io) { StringIO.new }

      describe "#write" do
        it "writes to the underlying file descriptor" do
          rd, wr = IO.pipe
          connection = Connection.new(nil_io, wr)
          connection.write("some data")
          wr.close

          expect(rd.read).to eq("some data")
        end

        it "writes large amounts of data" do
          port = Support.tcp_port

          server_thr = Thread.new do
            read_result = ""

            TCPServer.open("127.0.0.1", port) do |server|
              client = server.accept

              loop do
                begin
                  read_result << client.readpartial(1024 * 16)
                rescue EOFError
                  break
                end
              end
              client.close
            end

            read_result
          end

          begin
            socket = Socket.tcp("127.0.0.1", port)
          rescue Errno::ECONNREFUSED
            retry
          end

          big_data = Array.new(1024 * 16) { SecureRandom.hex(4) }.join
          connection = Connection.new(nil_io, socket)

          connection.write(big_data)
          socket.close
          expect(server_thr.value).to eq(big_data)
        end
      end

      describe "#read" do
        it "yields data from the underlying file descriptor" do
          rd, wr = IO.pipe
          wr.write("some data")
          wr.close

          connection = Connection.new(rd, nil_io)

          expect do |y|
            connection.read(&y)
          end.to yield_with_args("some data")
        end
      end

      describe "#close" do
        it "closes IO handles" do
          rd, wr = ::IO.pipe
          Connection.new(rd, wr).close

          expect(rd).to be_closed
          expect(wr).to be_closed
        end

        it "kills spawned processes" do
          io = ::IO.popen("cat", "rb+")
          pid = io.pid
          expect(pid).to respond_to(:to_int)

          Connection.new(io, nil_io).close
          expect { Process.kill(0, pid) }.to raise_error(Errno::ESRCH)
        end
      end
    end
  end
end
