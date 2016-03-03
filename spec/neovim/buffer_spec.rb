require "helper"

module Neovim
  RSpec.describe Buffer do
    let(:client) { Neovim.attach_child(["--headless", "-n", "-u", "NONE"]) }
    let(:buffer) { client.current.buffer }

    describe "#lines" do
      it "returns a LineRange" do
        expect(buffer.lines).to be_a(LineRange)
      end
    end

    describe "#lines=" do
      it "updates the buffer's lines" do
        buffer.lines = ["one", "two"]
        expect(buffer.lines.to_a).to eq(["one", "two"])
      end
    end

    describe "#range" do
      it "returns a LineRange" do
        expect(buffer.range).to be_a(LineRange)
      end
    end

    describe "#range=" do
      it "updates the buffer's range" do
        buffer.lines = ["one", "two", "three"]
        buffer.range = (0..1)
        expect(buffer.range.to_a).to eq(["one", "two"])
      end
    end
  end
end
