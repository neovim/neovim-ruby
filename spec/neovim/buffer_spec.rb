require "helper"

module Neovim
  RSpec.describe Buffer do
    let(:client) { Neovim.attach_child(["--headless", "-n", "-u", "NONE"]) }
    let(:buffer) { client.current.buffer }

    describe "#lines" do
      before do
        client.command("normal i1")
        client.command("normal o2")
        client.command("normal o3")
      end

      it "returns the buffer's lines as an array" do
        expect(buffer.lines.to_a).to eq(["1", "2", "3"])
      end

      it "can be indexed into" do
        expect(buffer.lines[1]).to eq("2")
      end

      it "can be sliced with a length" do
        expect(buffer.lines[0, 2]).to eq(["1", "2"])
      end

      it "can be sliced with a range" do
        expect(buffer.lines[0..1]).to eq(["1", "2"])
      end

      it "can be updated at an index" do
        buffer.lines[0] = "foo"
        expect(buffer.lines.to_a).to eq(["foo", "2", "3"])
      end

      it "can be updated with a length" do
        buffer.lines[0, 2] = ["foo"]
        expect(buffer.lines.to_a).to eq(["foo", "3"])
      end

      it "can be updated with a range" do
        buffer.lines[0..1] = ["foo"]
        expect(buffer.lines.to_a).to eq(["foo", "3"])
      end

      it "exposes the Enumerable interface" do
        succ_lines = buffer.lines.collect(&:succ)
        expect(succ_lines.to_a).to eq(["2", "3", "4"])
      end
    end

    describe "#lines=" do
      it "updates the buffers lines" do
        buffer.lines = ["one", "two"]
        expect(buffer.lines.to_a).to eq(["one", "two"])
      end
    end
  end
end
