require "helper"

module Neovim
  RSpec.describe Buffer do
    let(:client) { Neovim.attach_child(["nvim", "-n", "-u", "NONE"]) }
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

    describe "if_ruby compatibility" do
      describe "#name" do
        it "returns the buffer path as a string" do
          buffer.set_name("test_buf")

          expect(File.basename(buffer.name)).
            to end_with("test_buf")
        end
      end

      describe "#number" do
        it "returns the buffer index" do
          expect(buffer.number).to be(1)
        end
      end

      describe "#count" do
        it "returns the number of lines" do
          buffer.lines = ["one", "two", "three"]
          expect(buffer.count).to be(3)
        end
      end

      describe "#length" do
        it "returns the number of lines" do
          buffer.lines = ["one", "two", "three"]
          expect(buffer.length).to be(3)
        end
      end

      describe "#[]" do
        it "returns the given line" do
          buffer.lines = ["one", "two", "three"]
          expect(buffer[2]).to eq("two")
        end
      end

      describe "#[]=" do
        it "sets the given line" do
          buffer.lines = ["first", "second"]

          expect {
            buffer[2] = "last"
          }.to change { buffer.lines.to_a }.to(["first", "last"])
        end

        it "returns the line" do
          expect(buffer[0] = "first").to eq("first")
        end

        it "raises an out of bounds exception" do
          expect {
            buffer[10] = "line"
          }.to raise_error(/out of bounds/)
        end
      end

      describe "#delete" do
        it "deletes the line at the given index" do
          buffer.lines = ["one", "two"]

          expect {
            buffer.delete(1)
          }.to change { buffer.lines }.to(["two"])
        end
      end

      describe "#append" do
        it "adds a line after the given index" do
          buffer.lines = ["one"]

          expect {
            buffer.append(1, "two")
          }.to change { buffer.lines.to_a }.to(["one", "two"])
        end

        it "returns the appended line" do
          expect(buffer.append(0, "two")).to eq("two")
        end
      end

      describe "#line" do
        it "returns the current line on an active buffer" do
          buffer.lines = ["one", "two"]
          expect(buffer.line).to eq("one")
          client.command("normal j")
          expect(buffer.line).to eq("two")
        end

        it "returns nil on an inactive buffer" do
          original = buffer
          client.command("vnew")
          expect(original.line).to be(nil)
        end
      end

      describe "#line=" do
        it "sets the current line on an active buffer" do
          expect {
            buffer.line = "line"
          }.to change { buffer.lines }.to(["line"])
        end

        it "has no effect when called on an inactive buffer" do
          original = buffer
          client.command("vnew")
          original.line = "line"

          expect(original.lines.to_a).to eq([""])
          expect(client.current.buffer.lines.to_a).to eq([""])
        end
      end

      describe "#line_number" do
        it "returns the current line number on an active buffer" do
          client.command("normal oone")
          expect(buffer.line_number).to be(2)
        end

        it "returns nil on an inactive buffer" do
          original = buffer
          client.command("vnew")

          expect(original.line_number).to be(nil)
        end
      end
    end
  end
end
