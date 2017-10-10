require "helper"
require "securerandom"
require "neovim/event_loop/connection"

module Neovim
  class EventLoop
    RSpec.describe Connection do
      describe "#write" do
        it "writes to the underlying file descriptor" do
          rd, wr = IO.pipe
          connection = Connection.new(nil, wr)
          connection.write("some data")
          wr.close

          expect(rd.read).to eq("some data")
        end

        it "writes large amounts of data" do
          File.open(Support.file_path("io"), "w+") do |io|
            connection = Connection.new(nil, io)
            big_data = Array.new(1024 * 16) { SecureRandom.hex(4) }.join

            connection = Connection.new(nil, io)
            connection.write(big_data)

            expect(File.read(io.path)).to eq(big_data)
          end
        end
      end

      describe "#read" do
        it "yields data from the underlying file descriptor" do
          rd, wr = IO.pipe
          wr.write("some data")
          wr.close

          connection = Connection.new(rd, nil)

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

          Connection.new(io).close
          expect { Process.kill(0, pid) }.to raise_error(Errno::ESRCH)
        end
      end
    end
  end
end
