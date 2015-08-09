require "helper"
require "msgpack"

module Neovim
  RSpec.describe RPC, :remote do
    let(:stream) { StringIO.new.set_encoding("ASCII-8BIT") }
    let(:rpc)    { RPC.new(stream, @client) }

    describe "#request" do
      it "encodes the data and writes it to the stream" do
        message = MessagePack.pack([0, 0, :my_method, [1, "x"]])
        rpc.request(:my_method, 1, "x")
        expect(stream.string).to eq(message)
      end
    end

    describe "#response" do
      it "decodes the response data and returns its value" do
        payload = MessagePack.pack([0, 0, nil, "response"])
        stream.write(payload)
        stream.rewind

        expect(rpc.response).to eq("response")
      end

      it "raises an exception if an error is returned" do
        error_payload = MessagePack.pack([0, 0, "error message", nil])
        stream.write(error_payload)
        stream.rewind

        expect {
          rpc.response
        }.to raise_error(Neovim::RPC::Error, /error message/)
      end
    end

    describe "#register_types" do
      it "registers types with the packer and unpacker" do
        rpc.register_types("Buffer" => {"id" => 123})
        packer = rpc.instance_variable_get(:@packer)
        unpacker = rpc.instance_variable_get(:@unpacker)

        expect(packer.registered_types).to match([
          :type => 123,
          :class => Buffer,
          :packer => kind_of(Proc)
        ])

        expect(unpacker.registered_types).to match([
          :type => 123,
          :class => nil,
          :unpacker => kind_of(Proc)
        ])
      end
    end
  end
end
