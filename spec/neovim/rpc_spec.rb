require "helper"
require "msgpack"

module Neovim
  describe RPC do
    let(:stream) { StringIO.new }
    let(:rpc)    { RPC.new(stream) }

    describe "#send" do
      it "encodes the data and writes it to the stream" do
        message = MessagePack.pack([0, 0, :my_method, [1, "x"]])
        expect(stream).to receive(:write).with(message)

        rpc.send(:my_method, 1, "x")
      end
    end

    describe "#response" do
      it "decodes the response data and returns its value" do
        response = MessagePack.pack([0, 0, nil, "response"])
        expect(stream).to receive(:read).and_return(response)

        expect(rpc.response).to eq("response")
      end

      it "raises an exception if an error is returned" do
        error_response = MessagePack.pack([0, 0, "error message", nil])
        expect(stream).to receive(:read).and_return(error_response)

        expect {
          rpc.response
        }.to raise_error(Neovim::RPC::Error, /error message/)
      end
    end
  end
end
