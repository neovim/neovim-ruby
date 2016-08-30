require "helper"

module Neovim
  class Session
    RSpec.describe Request do
      let(:serializer) { double(:serializer) }
      let(:reqid) { 1 }
      let(:request) { Request.new(:method, ["arg"], serializer, reqid) }

      it "has readers" do
        expect(request.method_name).to eq("method")
        expect(request.arguments).to eq(["arg"])
      end

      describe "#sync?" do
        it "is true" do
          expect(request.sync?).to be(true)
        end
      end

      describe "#respond" do
        it "writes an RPC response to serializer" do
          expect(serializer).to receive(:write).with([1, reqid, nil, "val"])
          request.respond("val")
        end
      end

      describe "#error" do
        it "writes an RPC error response to serializer" do
          expect(serializer).to receive(:write).with([1, reqid, "err", nil])
          request.error("err")
        end
      end
    end
  end
end
