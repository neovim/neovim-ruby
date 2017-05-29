require "helper"

module Neovim
  RSpec.describe Buffer do
    let(:client) { Neovim.attach_child(Support.child_argv) }
    let(:buffer) { client.current.buffer }
    after { client.shutdown }

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
  end
end
