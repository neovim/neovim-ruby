require "helper"

module Neovim
  RSpec.describe MsgpackStream do
    it "receives msgpack messages" do
      server = Server.unix("/tmp/#{$$}.sock")
      stream = MsgpackStream.new(server)
      messages = []

      thr = Thread.new do
        stream.run do |message|
          messages << message
          stream.stop
        end
      end

      IO.popen(["/usr/bin/nc", "-U", "/tmp/#{$$}.sock"], "rb+") do |io|
        io.write(MessagePack.pack({:foo => "bar"}))
        io.close_write
      end

      thr.join
      expect(messages).to eq([{"foo" => "bar"}])
    end

    it "sends msgpack messages"
  end
end
