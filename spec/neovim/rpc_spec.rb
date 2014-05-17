require "helper"
require "msgpack"
require "neovim/rpc"

module Neovim
  describe RPC do
    let(:message)  { {"message" => "Hello"} }
    let(:response) { {"response" => "Hi"} }

    let(:stream) do
      double(:stream, read: MessagePack.pack(response), write: nil)
    end

    describe "#initialize" do
      it "encodes the data and writes it to the stream" do
        packed_message = MessagePack.pack(message)
        expect(stream).to receive(:write).with(packed_message)
        RPC.new({message: "Hello"}, stream)
      end
    end

    describe "#response" do
      it "reads from the stream and decodes the message" do
        packed_response = MessagePack.pack(response)

        stream.stub(:read).and_return(packed_response)
        rpc = RPC.new(message, stream)
        expect(rpc.response).to eq(response)
      end
    end
  end
end
