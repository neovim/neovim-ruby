require "helper"

module Neovim
  describe RPC do
    let(:message)  { [0, 0, 1, []] }
    let(:response) { [0, 0, nil, nil] }

    let(:stream) do
      double(:stream).tap do |stream|
        allow(stream).to receive(:write) { stream }
      end
    end

    it "encodes the data, writes it to the stream, and decodes the response" do
      expect(stream).to receive(:read) { MessagePack.pack(response) }
      expect(RPC.new(stream).write(message)).to eq(response)
    end

    it "raises an exception if an error is returned" do
      error_response = MessagePack.pack([0, 0, "error message", nil])
      expect(stream).to receive(:read) { error_response }

      expect {
        RPC.new(stream).write(message)
      }.to raise_error(Neovim::RPC::Error, /error message/)
    end
  end
end
