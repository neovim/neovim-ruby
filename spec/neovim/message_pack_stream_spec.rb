require "helper"
require "msgpack"

module Neovim
  RSpec.describe MessagePackStream, :remote do
    let(:io)  { StringIO.new.set_encoding("ASCII-8BIT") }
    let(:rpc) { MessagePackStream.new(io, @client) }

    describe "#request" do
      it "encodes the data and writes it to the stream" do
        message = MessagePack.pack([0, 0, :my_method, [1, "x"]])
        rpc.request(:my_method, 1, "x")
        expect(io.string).to eq(message)
      end
    end

    describe "#response" do
      it "decodes the response data and returns its value" do
        payload = MessagePack.pack([0, 0, nil, "response"])
        io.write(payload)
        io.rewind

        expect(rpc.response).to eq("response")
      end

      it "raises an exception if an error is returned" do
        error_payload = MessagePack.pack([0, 0, "error message", nil])
        io.write(error_payload)
        io.rewind

        expect {
          rpc.response
        }.to raise_error(Neovim::MessagePackStream::Error, /error message/)
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
