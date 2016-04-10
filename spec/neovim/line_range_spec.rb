require "helper"

module Neovim
  RSpec.describe LineRange do
    let(:client) { Neovim.attach_child(["nvim", "--headless", "-n", "-u", "NONE"]) }
    let(:buffer) { client.current.buffer }
    let(:line_range) { LineRange.new(buffer, 0, -1) }

    before do
      client.command("normal i1")
      client.command("normal o2")
      client.command("normal o3")
    end

    it "is enumerable" do
      expect(line_range).to be_an(Enumerable)
      expect(line_range).to respond_to(:each)
    end

    describe "#to_a" do
      it "returns lines as an array" do
        expect(line_range.to_a).to eq(["1", "2", "3"])
      end
    end

    describe "#[]" do
      it "accepts a single index" do
        expect(line_range[1]).to eq("2")
      end

      it "accepts an index and length" do
        expect(line_range[0, 2].to_a).to eq(["1", "2"])
      end

      it "accepts a range" do
        expect(line_range[0..1].to_a).to eq(["1", "2"])
        expect(line_range[0...1].to_a).to eq(["1"])
      end
    end

    describe "#[]=" do
      it "accepts a single index" do
        line_range[0] = "foo"
        expect(line_range.to_a).to eq(["foo", "2", "3"])
      end

      it "accepts an index and length" do
        line_range[0, 2] = ["foo"]
        expect(line_range.to_a).to eq(["foo", "3"])
      end

      it "accepts a range" do
        line_range[0..1] = ["foo"]
        expect(line_range.to_a).to eq(["foo", "3"])

        line_range[0...1] = ["bar"]
        expect(line_range.to_a).to eq(["bar", "3"])
      end
    end

    describe "#replace" do
      it "replaces all lines" do
        line_range.replace(["5", "6"])
        expect(line_range.to_a).to eq(["5", "6"])
      end
    end

    describe "#delete" do
      it "deletes the line at the given index" do
        line_range.replace(["one", "two"])

        expect {
          line_range.delete(0)
        }.to change { line_range.to_a }.to(["two"])
      end
    end
  end
end
