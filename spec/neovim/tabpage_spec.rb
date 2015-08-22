require "helper"

module Neovim
  RSpec.describe Tabpage do
    include Support::Remote

    around do |spec|
      with_neovim_connection(:embed) do |conn|
        rpc = RPC.new(conn)
        @tabpage = Tabpage.new(3, rpc)
        spec.run
      end
    end

    describe "#respond_to?" do
      it "returns true for Tabpage functions" do
        expect(@tabpage).to respond_to(:is_valid)
      end

      it "returns true for Ruby functions" do
        expect(@tabpage).to respond_to(:inspect)
      end

      it "returns false otherwise" do
        expect(@tabpage).not_to respond_to(:foobar)
      end
    end

    describe "#method_missing" do
      it "enables tabpage_* function calls" do
        expect(@tabpage.is_valid).to be(true)
      end
    end
  end
end
