require "helper"

module Neovim
  RSpec.describe Window do
    let(:window) { Neovim.attach_child(["-n", "-u", "NONE"]).current.window }

    describe "#respond_to?" do
      it "returns true for Window functions" do
        expect(window).to respond_to(:get_cursor)
      end

      it "returns true for Ruby functions" do
        expect(window).to respond_to(:inspect)
      end

      it "returns false otherwise" do
        expect(window).not_to respond_to(:foobar)
      end
    end

    describe "#method_missing" do
      it "enables window_* function calls" do
        expect(window.get_cursor).to eq([1, 0])
      end
    end

    describe "#methods" do
      it "returns builtin methods" do
        expect(window.methods).to include(:inspect)
      end

      it "returns api methods" do
        expect(window.methods).to include(:get_height)
      end
    end
  end
end
