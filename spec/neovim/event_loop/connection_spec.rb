require "helper"

module Neovim
  class EventLoop
    RSpec.describe Connection do
      let(:nil_io) { StringIO.new }

      describe "#write" do
        it "writes msgpack to the underlying file descriptor" do
          rd, wr = IO.pipe
          connection = Connection.new(nil_io, wr)
          connection.write("some data")
          wr.close

          expect(MessagePack.unpack(rd.read)).to eq("some data")
        end
      end

      describe "#read" do
        it "yields data from the underlying file descriptor" do
          rd, wr = IO.pipe
          wr.write(MessagePack.pack("some data"))
          wr.close

          connection = Connection.new(rd, nil_io)

          expect do |y|
            connection.read(&y)
          end.to yield_with_args("some data")
        end
      end

      describe "#register_type" do
        it "registers a msgpack ext type" do
          ext_class = Struct.new(:id) do
            def self.from_msgpack_ext(data)
              new(data.unpack('N')[0])
            end

            def to_msgpack_ext
              [self.id].pack('C')
            end
          end

          client_rd, server_wr = IO.pipe
          server_rd, client_wr = IO.pipe

          connection = Connection.new(client_rd, client_wr)

          connection.register_type(42) do |id|
            ext_class.new(id)
          end

          factory = MessagePack::Factory.new
          factory.register_type(42, ext_class)
          obj = ext_class.new(1)
          factory.packer(server_wr).write(obj).flush

          expect do |block|
            connection.read(&block)
          end.to yield_with_args(obj)
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
