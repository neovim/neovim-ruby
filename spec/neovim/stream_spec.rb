require "helper"
require "msgpack"
require "neovim/stream"

module Neovim
  describe Stream do
    describe "using a UNIX domain socket" do
      let(:socket_path) do
        ENV.fetch("NEOVIM_LISTEN_ADDRESS", "/tmp/neovim.sock")
      end

      before do
        unless File.socket?(socket_path)
          raise("Neovim isn't running. Run it with `NEOVIM_LISTEN_ADDRESS=#{socket_path} nvim`")
        end
      end

      it "writes data and reads responses" do
        stream = Stream.new(socket_path, nil)
        message = MessagePack.pack([0, 0, 0, []])
        stream.write(message)
        response = MessagePack.unpack(stream.read)

        expect(response).to respond_to(:to_ary)
        expect(response.size).to eq(4)
      end
    end
  end
end
