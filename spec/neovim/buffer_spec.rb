require "helper"

module Neovim
  RSpec.describe Buffer, :remote do
    let(:buffer) { Buffer.new(2, @client) } # I don't know why it has to be 2

    describe "#length" do
      it "returns the length of the buffer" do
        expect(buffer.length).to eq(1)
      end
    end

    describe "#lines" do
      it "returns an enumerable of strings" do
        expect(buffer.lines.to_a).to eq([""])
      end

      it "allows access to individual lines" do
        buffer.lines[0] = "first line"
        expect(buffer.lines[0]).to eq("first line")
      end

      it "allows access to a range of lines" do
        buffer.lines[0..1] = ["first line", "second line"]
        expect(buffer.lines[0..1]).to eq(["first line", "second line"])
      end

      it "can be mutated" do
        buffer.lines = ["first line", "second line"]
        expect(buffer.lines.to_a).to eq(["first line", "second line"])
      end

      it "can be mutated at an index" do
        buffer.lines[0] = "first line"
        expect(buffer.lines.to_a).to eq(["first line"])
      end

      it "can be deleted at an index" do
        buffer.lines = ["first line", "second line"]
        expect(buffer.lines.delete_at(0)).to eq("first line")
        expect(buffer.lines.to_a).to eq(["second line"])
      end

      it "can be mutated using a slice" do
        buffer.lines = ["first", "second", "third"]
        buffer.lines[0..1] = ["new first", "new second"]
        expect(buffer.lines.to_a).to eq(["new first", "new second", "third"])
      end

      it "returns the lines" do
        expect(buffer.lines = ["line"]).to eq(["line"])
      end
    end

    describe "#insert" do
      it "inserts lines after the given index" do
        buffer.lines = ["first", "last"]
        buffer.insert(0, ["foo", "bar"])
        expect(buffer.lines.to_a).to eq(["first", "foo", "bar", "last"])
      end

      it "returns the buffer" do
        expect(buffer.insert(0, ["line"])).to eq(buffer)
      end
    end

    describe "#variable" do
      it "reads a buffer local variable" do
        variable = buffer.variable("test_var")

        expect(variable).to be_a(Variable)
        expect(variable.name).to eq("test_var")
        expect(variable.scope).to be_a(Scope::Buffer)
      end
    end

    describe "#option" do
      it "reads a buffer local option" do
        option = buffer.option("expandtab")

        expect(option).to be_a(Option)
        expect(option.name).to eq("expandtab")
        expect(option.scope).to be_a(Scope::Buffer)
      end
    end

    describe "#number" do
      it "returns the buffer index" do
        expect(buffer.number).to eq(1)
      end
    end

    describe "#name" do
      it "returns the buffer name" do
        @client.command("file buffer_abc")
        expect(buffer.name).to match(/buffer_abc$/)
      end
    end

    describe "#name=" do
      it "sets the buffer name" do
        buffer.name = "buffer_abc"
        expect(buffer.name).to match(/buffer_abc$/)
      end

      it "returns the buffer name" do
        expect(buffer.name = "buffer").to eq("buffer")
      end
    end

    describe "#valid?" do
      it "returns true" do
        expect(buffer).to be_valid
      end

      it "returns false" do
        skip "I don't know what this means"
      end
    end

    describe "#mark" do
      it "returns the position of the provided mark" do
        buffer.lines = ["one", "two", "three"]
        @client.command("normal jlma")
        expect(buffer.mark("a")).to eq([2, 1])
      end
    end
  end
end
