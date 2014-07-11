require "helper"

module Neovim
  describe Stream, :remote => true do
    describe "using a UNIX domain socket" do
      it "writes data and reads responses" do
        stream = Neovim::Stream.new("/tmp/neovim.sock", nil)
        message = MessagePack.pack([0, 0, 0, []])

        response = stream.write(message).read
        expect(response).to respond_to(:to_str)
        expect(response).not_to be_empty

        payload = MessagePack.unpack(response)
        expect(payload).to respond_to(:to_ary)
        expect(payload.size).to eq(4)
      end
    end
  end
end
