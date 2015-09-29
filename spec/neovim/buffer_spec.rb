require "helper"

module Neovim
  RSpec.describe Buffer do
    let(:buffer) { Neovim.attach_child(["-u", "NONE"]).current.buffer }

    describe "#respond_to?" do
      it "returns true for Buffer functions" do
        expect(buffer).to respond_to(:line_count)
      end

      it "returns true for Ruby functions" do
        expect(buffer).to respond_to(:inspect)
      end

      it "returns false otherwise" do
        expect(buffer).not_to respond_to(:foobar)
      end
    end

    describe "#method_missing" do
      it "enables buffer_* function calls" do
        expect(buffer.line_count).to be(1)
      end
    end
  end
end
