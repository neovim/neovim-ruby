require "helper"

module Neovim
  RSpec.describe Window do
    include Support::Remote

    around do |spec|
      with_neovim_connection(:embed) do |conn|
        rpc = RPC.new(conn)
        @window = Window.new(1, rpc)
        spec.run
      end
    end

    describe "#respond_to?" do
      it "returns true for Window functions" do
        expect(@window).to respond_to(:get_cursor)
      end

      it "returns true for Ruby functions" do
        expect(@window).to respond_to(:inspect)
      end

      it "returns false otherwise" do
        expect(@window).not_to respond_to(:foobar)
      end
    end

    describe "#method_missing" do
      it "enables window_* function calls" do
        expect(@window.get_cursor).to eq([1, 0])
      end
    end
  end
end
