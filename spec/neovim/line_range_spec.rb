require "helper"

module Neovim
  RSpec.describe LineRange do
    let(:client) { Support.persistent_client }
    let(:buffer) { client.current.buffer }
    let(:line_range) { LineRange.new(buffer) }

    before do
      buffer.set_lines(0, -1, true, ["1", "2", "3", "4"])
    end

    describe "#each" do
      it "yields each line" do
        yielded = []
        line_range.each { |line| yielded << line }

        expect(yielded).to eq(["1", "2", "3", "4"])
      end

      it "yields a large number of lines" do
        lines = Array.new(6000, "x")
        buffer.set_lines(0, -1, true, lines)

        yielded = []
        line_range.each { |line| yielded << line }

        expect(yielded).to eq(lines)
      end
    end

    describe "#to_a" do
      it "returns lines as an array" do
        expect(line_range.to_a).to eq(["1", "2", "3", "4"])
      end

      it "returns a large number of lines as an array" do
        lines = Array.new(6000, "x")
        buffer.set_lines(0, -1, true, lines)
        expect(line_range.to_a).to eq(lines)
      end
    end

    describe "#==" do
      it "compares line contents" do
        client.command("new")
        buffer2 = client.current.buffer

        expect(buffer2.lines == buffer.lines).to eq(false)
        buffer2.set_lines(0, -1, true, ["1", "2", "3", "4"])
        expect(buffer2.lines == buffer.lines).to eq(true)
      end
    end

    describe "#[]" do
      it "accepts a single index" do
        expect(line_range[1]).to eq("2")
        expect(line_range[-1]).to eq("4")
        expect(line_range[-2]).to eq("3")
      end

      it "accepts an index and length" do
        expect(line_range[0, 2]).to eq(["1", "2"])
        expect(line_range[-2, 2]).to eq(["3", "4"])
        expect(line_range[-2, 3]).to eq(["3", "4"])

        expect do
          line_range[2, 3]
        end.to raise_error(/out of bounds/)
      end

      it "accepts a range" do
        expect(line_range[0..1]).to eq(["1", "2"])
        expect(line_range[0...1]).to eq(["1"])

        expect(line_range[0..-1]).to eq(["1", "2", "3", "4"])
        expect(line_range[0..-2]).to eq(["1", "2", "3"])
        expect(line_range[-3..-2]).to eq(["2", "3"])

        expect(line_range[0..-5]).to eq([])
        expect(line_range[0...-4]).to eq([])
        expect(line_range[-2..-3]).to eq([])

        expect do
          line_range[2..4]
        end.to raise_error(/out of bounds/)
      end
    end

    describe "#[]=" do
      it "accepts a single index" do
        expect(line_range[0] = "foo").to eq("foo")
        expect(line_range.to_a).to eq(["foo", "2", "3", "4"])

        expect(line_range[-1] = "bar").to eq("bar")
        expect(line_range.to_a).to eq(["foo", "2", "3", "bar"])

        expect do
          line_range[-5] = "foo"
        end.to raise_error(/out of bounds/)
      end

      it "accepts an index and length" do
        expect(line_range[0, 2] = ["foo"]).to eq(["foo"])
        expect(line_range.to_a).to eq(["foo", "3", "4"])

        expect(line_range[-2, 2] = ["bar"]).to eq(["bar"])
        expect(line_range.to_a).to eq(["foo", "bar"])

        expect(line_range[0, 2] = "baz").to eq("baz")
        expect(line_range.to_a).to eq(["baz"])

        expect do
          line_range[0, 5] = "foo"
        end.to raise_error(/out of bounds/)
      end

      it "accepts a range" do
        expect(line_range[0..1] = ["foo"]).to eq(["foo"])
        expect(line_range.to_a).to eq(["foo", "3", "4"])

        expect(line_range[0...1] = ["bar"]).to eq(["bar"])
        expect(line_range.to_a).to eq(["bar", "3", "4"])

        expect(line_range[0..-2] = ["baz"]).to eq(["baz"])
        expect(line_range.to_a).to eq(["baz", "4"])

        expect(line_range[0...2] = "qux").to eq("qux")
        expect(line_range.to_a).to eq(["qux"])
      end
    end

    describe "#replace" do
      it "replaces all lines" do
        line_range.replace(["4", "5"])
        expect(line_range.to_a).to eq(["4", "5"])
      end
    end

    describe "#delete" do
      it "deletes the line at the given index" do
        expect do
          line_range.delete(0)
        end.to change { line_range.to_a }.to(["2", "3", "4"])

        expect do
          line_range.delete(-1)
        end.to change { line_range.to_a }.to(["2", "3"])

        expect do
          line_range.delete(-2)
        end.to change { line_range.to_a }.to(["3"])
      end

      it "returns the line deleted" do
        expect(line_range.delete(0)).to eq("1")
        expect(line_range.delete(-1)).to eq("4")
      end

      it "returns nil if provided a non-integer" do
        expect do
          expect(line_range.delete(:foo)).to eq(nil)
        end.not_to change { line_range.to_a }
      end
    end
  end
end
