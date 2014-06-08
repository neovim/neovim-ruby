require "helper"

module Neovim
  describe RPC do
    let(:message)  { [0, 0, 1, []] }
    let(:response) { [0, 0, nil, nil] }

    let(:stream) do
      double(:stream, read: MessagePack.pack(response), write: nil)
    end

    it "encodes the data and writes it to the stream" do
      packed_message = MessagePack.pack(message)
      expect(stream).to receive(:write).with(packed_message)
      RPC.new(message, stream)
    end

    it "reads from the stream and decodes the message" do
      packed_response = MessagePack.pack(response)
      expect(stream).to receive(:read).and_return(packed_response)
      rpc = RPC.new(message, stream)
      expect(rpc.response).to eq(response)
    end

    it "raises an exception if an error is returned" do
      error_response = [0, 0, "error message", nil]
      expect(stream).to receive(:read).and_return(MessagePack.pack(error_response))
      expect {
        RPC.new(message, stream).response
      }.to raise_error(Neovim::RPC::Error, "error message")
    end
  end
end
