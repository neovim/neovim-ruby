require "helper"
require "fileutils"

module Neovim
  RSpec.describe Connection do
    before { FileUtils.rm_f("/tmp/test.sock") }

    describe ".parse" do
      it "receives an IO object" do
        IO.pipe do |rd, wr|
          expect(Connection.parse(rd).to_io).to be_a(IO)
        end
      end

      it "receives a UNIX socket string" do
        UNIXServer.open("/tmp/test.sock") do
          expect(Connection.parse("/tmp/test.sock").to_io).to be_a(UNIXSocket)
        end
      end

      it "receives a UNIX socket path" do
        UNIXServer.open("/tmp/test.sock") do
          path = Pathname.new("/tmp/test.sock")
          expect(Connection.parse(path).to_io).to be_a(UNIXSocket)
        end
      end

      it "receives a TCP socket string" do
        TCPServer.open("127.0.0.1", 3333) do
          expect(Connection.parse("127.0.0.1:3333").to_io).to be_a(TCPSocket)
        end
      end

      it "raises an exception" do
        expect {
          Connection.parse("foobar")
        }.to raise_error(Connection::Error, /No such file or directory/)

        expect {
          Connection.parse("127.0.0.1:80")
        }.to raise_error(Connection::Error, /Connection refused/)

        expect {
          Connection.parse({})
        }.to raise_error(Connection::Error, /Can't connect to object '{}'/)
      end
    end
  end
end
