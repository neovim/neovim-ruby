require "helper"

module Neovim
  RSpec.describe Connection do
    let(:nil_io) { StringIO.new }

    describe "#write" do
      it "writes msgpack to the underlying file descriptor" do
        rd, wr = IO.pipe
        Connection.new(nil_io, wr).write("some data").flush
        data = rd.readpartial(1024)

        expect(MessagePack.unpack(data)).to eq("some data")
      end
    end

    describe "#flush" do
      it "flushes writes to the underlying file descriptor" do
        rd, wr = IO.pipe
        connection = Connection.new(nil_io, wr).write("some data")

        expect { rd.read_nonblock(16) }.to raise_error(IO::WaitReadable)

        connection.flush

        expect(rd.read_nonblock(16)).to eq(MessagePack.pack("some data"))
      end

      it "throws an exception when the file is closed" do
        _, wr = IO.pipe
        connection = Connection.new(nil_io, wr).write("some data")
        wr.close

        expect { connection.flush }.to raise_error(IOError)
      end
    end

    describe "#read" do
      it "reads msgpack from the underlying file descriptor" do
        rd, wr = IO.pipe
        wr.write(MessagePack.pack("some data"))
        wr.flush

        connection = Connection.new(rd, nil_io)
        expect(connection.read).to eq("some data")
      end

      it "throws an exception when the file is closed" do
        rd, wr = IO.pipe
        wr.close

        connection = Connection.new(rd, nil_io)
        expect { connection.read }.to raise_error(EOFError)
      end
    end

    describe "#register_type" do
      it "registers a msgpack ext type" do
        ext_class = Struct.new(:id) do
          def self.from_msgpack_ext(data)
            new(data.unpack("N")[0])
          end

          def to_msgpack_ext
            [id].pack("C")
          end
        end

        client_rd, server_wr = IO.pipe
        _, client_wr = IO.pipe

        connection = Connection.new(client_rd, client_wr)

        connection.register_type(42) do |id|
          ext_class.new(id)
        end

        factory = MessagePack::Factory.new
        factory.register_type(42, ext_class)
        obj = ext_class.new(1)
        factory.packer(server_wr).write(obj).flush

        expect(connection.read).to eq(obj)
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
        thr = Process.detach(pid)

        Connection.new(io, nil_io).close
        expect(thr.join.pid).to eq(pid)
      end
    end
  end
end
