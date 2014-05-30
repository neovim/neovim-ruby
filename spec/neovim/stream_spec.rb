require "helper"
require "msgpack"
require "neovim/stream"

module Neovim
  describe Stream do
    describe "using a UNIX domain socket", :remote => true do
      it "writes data and reads responses" do
        stream = Stream.new("/tmp/neovim.sock", nil)
        message = MessagePack.pack([0, 0, 0, []])
        stream.write(message)
        response = MessagePack.unpack(stream.read)

        expect(response).to respond_to(:to_ary)
        expect(response.size).to eq(4)
      end
    end
  end
end
