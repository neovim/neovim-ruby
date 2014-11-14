require "helper"
require "msgpack"

module Neovim
  RSpec.describe RPC, :remote => true do
    let(:stream) { StringIO.new }
    let(:rpc)    { RPC.new(stream, @client) }

    describe "#send" do
      it "encodes the data and writes it to the stream" do
        message = MessagePack.pack([0, 0, :my_method, [1, "x"]])
        expect(stream).to receive(:write).with(message)

        rpc.send(:my_method, 1, "x")
      end

      it "encodes nvim objects to their msgpack representation" do
        buffer = Buffer.new(2, @client)
        message = MessagePack.pack([0, 0, :my_method, [buffer.msgpack_data]])
        expect(stream).to receive(:write).with(message)

        rpc.send(:my_method, buffer)
      end
    end

    describe "#response" do
      it "decodes the response data and returns its value" do
        payload = MessagePack.pack([0, 0, nil, "response"])
        expect(stream).to receive(:read).and_return(payload)

        expect(rpc.response).to eq("response")
      end

      it "returns neovim objects" do
        type_code = @client.type_code_for(Buffer)
        extended = MessagePack::Extended.new(type_code, [2].pack("c*"))
        payload = MessagePack.pack([0, 0, nil, extended])

        expect(stream).to receive(:read).and_return(payload)

        response = rpc.response
        expect(response).to be_a(Buffer)
        expect(response.index).to eq(2)
      end

      it "returns arrays of neovim objects" do
        type_code = @client.type_code_for(Buffer)
        extended = MessagePack::Extended.new(type_code, [2].pack("c*"))
        payload = MessagePack.pack([0, 0, nil, [extended]])

        expect(stream).to receive(:read).and_return(payload)

        response = rpc.response
        expect(response.first).to be_a(Buffer)
        expect(response.first.index).to eq(2)
      end

      it "raises an exception if an error is returned" do
        error_payload = MessagePack.pack([0, 0, "error message", nil])
        expect(stream).to receive(:read).and_return(error_payload)

        expect {
          rpc.response
        }.to raise_error(Neovim::RPC::Error, /error message/)
      end
    end
  end
end
