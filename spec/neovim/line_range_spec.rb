require "helper"

module Neovim
  RSpec.describe LineRange do
    let(:client) { Neovim.attach_child(Support.child_argv) }
    let(:buffer) { client.current.buffer }
    let(:line_range) { LineRange.new(buffer, 0, -1) }
    let(:sub_range) { LineRange.new(buffer, 1, 2) }

    before do
      client.command("normal i1")
      client.command("normal o2")
      client.command("normal o3")
      client.command("normal o4")
    end

    after { client.shutdown }

    it "is enumerable" do
      expect(line_range).to be_an(Enumerable)
      expect(line_range).to respond_to(:each)
    end

    describe "#to_a" do
      it "returns lines as an array" do
        expect(line_range.to_a).to eq(["1", "2", "3", "4"])
      end

      it "returns a subset of lines as an array" do
        expect(sub_range.to_a).to eq(["2", "3"])
      end
    end

    describe "#[]" do
      it "accepts a single index" do
        expect(line_range[1]).to eq("2")
      end

      it "returns lines at an offset from the index" do
        expect(sub_range[0]).to eq("2")
      end

      it "allows indexes beyond the bounds of a sub range" do
        expect(sub_range[2]).to eq("4")
      end

      it "returns lines at an offset with a negative index" do
        expect(sub_range[-1]).to eq("3")
      end

      it "accepts an index and length" do
        expect(line_range[0, 2].to_a).to eq(["1", "2"])
      end

      it "returns lines at an offset from an index and length" do
        expect(sub_range[0, 2].to_a).to eq(["2", "3"])
      end

      it "accepts a range" do
        expect(line_range[0..1].to_a).to eq(["1", "2"])
        expect(line_range[0...1].to_a).to eq(["1"])
      end

      it "accepts a range with a negative end" do
        expect(line_range[0..-1].to_a).to eq(["1", "2", "3", "4"])
      end

      it "returns lines at an offset from a range" do
        expect(sub_range[0..1].to_a).to eq(["2", "3"])
      end
    end

    describe "#[]=" do
      it "accepts a single index" do
        line_range[0] = "foo"
        expect(line_range.to_a).to eq(["foo", "2", "3", "4"])
      end

      it "accepts a single index at an offset" do
        sub_range[0] = "foo"
        expect(buffer.lines.to_a).to eq(["1", "foo", "3", "4"])
      end

      it "accepts an index and length" do
        line_range[0, 2] = ["foo"]
        expect(line_range.to_a).to eq(["foo", "3", "4"])
      end

      it "accepts an index and length at an offset" do
        sub_range[0, 2] = ["foo"]
        expect(buffer.lines.to_a).to eq(["1", "foo", "4"])
      end

      it "accepts a range" do
        line_range[0..1] = ["foo"]
        expect(line_range.to_a).to eq(["foo", "3", "4"])

        line_range[0...1] = ["bar"]
        expect(line_range.to_a).to eq(["bar", "3", "4"])
      end

      it "accepts a range at an offset" do
        sub_range[0..1] = ["foo"]
        expect(buffer.lines.to_a).to eq(["1", "foo", "4"])
      end
    end

    describe "#replace" do
      it "replaces all lines" do
        line_range.replace(["4", "5"])
        expect(line_range.to_a).to eq(["4", "5"])
      end

      it "replaces a subset of lines" do
        sub_range.replace(["5", "6"])
        expect(buffer.lines.to_a).to eq(["1", "5", "6", "4"])
      end
    end

    describe "#insert" do
      before { line_range.replace(["1", "2"]) }

      it "inserts lines at the beginning" do
        expect {
          line_range.insert(0, "z")
        }.to change { line_range.to_a }.to(["z", "1", "2"])

        expect {
          line_range.insert(0, ["x", "y"])
        }.to change { line_range.to_a }.to(["x", "y", "z", "1", "2"])
      end

      it "inserts lines in the middle" do
        expect {
          line_range.insert(1, "z")
        }.to change { line_range.to_a }.to(["1", "z", "2"])

        expect {
          line_range.insert(1, ["x", "y"])
        }.to change { line_range.to_a }.to(["1", "x", "y", "z", "2"])
      end

      it "inserts lines at the end" do
        expect {
          line_range.insert(-1, "x")
        }.to change { line_range.to_a }.to(["1", "2", "x"])

        expect {
          line_range.insert(-1, ["y", "z"])
        }.to change { line_range.to_a }.to(["1", "2", "x", "y", "z"])
      end

      it "raises on out of bounds indexes" do
        expect {
          line_range.insert(10, "x")
        }.to raise_error(/out of bounds/i)
      end
    end

    describe "#delete" do
      it "deletes the line at the given index" do
        expect {
          line_range.delete(0)
        }.to change { line_range.to_a }.to(["2", "3", "4"])
      end

      it "deletes the line at an offset" do
        expect {
          sub_range.delete(0)
        }.to change { buffer.lines.to_a }.to(["1", "3", "4"])
      end
    end
  end
end
