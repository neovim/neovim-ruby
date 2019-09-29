require "helper"

module Neovim
  RSpec.describe Buffer do
    let(:client) { Support.persistent_client }
    let(:buffer) { client.current.buffer }

    before do
      client.command("normal ione")
      client.command("normal otwo")
      client.command("normal gg")
    end

    describe "#lines" do
      it "returns a LineRange" do
        expect(buffer.lines).to be_a(LineRange)
      end
    end

    describe "#lines=" do
      it "updates the buffer's lines" do
        expect do
          buffer.lines = ["two", "three"]
        end.to change { buffer.lines.to_a }.to(["two", "three"])
      end
    end

    describe "#set_name", "#name" do
      it "updates the buffer name" do
        expect do
          buffer.set_name("test_buf")
        end.to change { buffer.name }.to(/test_buf$/)
      end
    end

    describe "#number" do
      it "returns the buffer number" do
        expect do
          client.command("new")
        end.to change { client.get_current_buf.number }
      end
    end

    describe "#count" do
      it "returns the number of lines" do
        expect do
          buffer.append(0, "zero")
        end.to change { buffer.count }.from(2).to(3)
      end
    end

    describe "#length" do
      it "returns the number of lines" do
        expect do
          buffer.append(0, "zero")
        end.to change { buffer.length }.from(2).to(3)
      end
    end

    describe "#[]" do
      it "returns the line at the line number" do
        expect(buffer[1]).to eq("one")
      end

      it "raises on out of bounds" do
        expect do
          buffer[-1]
        end.to raise_error(/out of bounds/)

        expect do
          buffer[4]
        end.to raise_error(/out of bounds/)
      end
    end

    describe "#[]=" do
      it "sets the line at the line number" do
        expect do
          buffer[1] = "first"
        end.to change { buffer[1] }.from("one").to("first")
      end

      it "raises on out of bounds" do
        expect do
          buffer[4] = "line"
        end.to raise_error(/out of bounds/)

        expect do
          buffer[-1] = "line"
        end.to raise_error(/out of bounds/)
      end
    end

    describe "#delete" do
      it "deletes at the line number" do
        expect do
          buffer.delete(2)
        end.to change { buffer.lines.to_a }.to(["one"])
      end

      it "raises on out of bounds" do
        expect do
          buffer.delete(-1)
        end.to raise_error(/out of bounds/)

        expect do
          buffer.delete(4)
        end.to raise_error(/out of bounds/)
      end
    end

    describe "#append" do
      it "appends after the line" do
        expect do
          buffer.append(2, "last")
        end.to change { buffer.lines.to_a }.to(["one", "two", "last"])
      end

      it "inserts before the first line" do
        expect do
          buffer.append(0, "first")
        end.to change { buffer.lines.to_a }.to(["first", "one", "two"])
      end

      it "allows newlines" do
        expect do
          buffer.append(0, "first\nsecond")
        end.to change { buffer.lines.to_a }.to(["first", "second", "one", "two"])
      end

      it "doesn't move the cursor" do
        expect do
          buffer.append(0, "first")
        end.not_to change { client.get_current_win.cursor }
      end

      it "raises on out of bounds" do
        expect do
          buffer.append(-1, "line")
        end.to raise_error(/out of bounds/)

        expect do
          buffer.append(4, "line")
        end.to raise_error(/out of bounds/)
      end
    end

    describe "#line_number" do
      it "returns the current line number" do
        expect do
          client.command("normal j")
        end.to change { buffer.line_number }.from(1).to(2)
      end

      it "returns nil on inactive buffers" do
        expect do
          client.command("new")
        end.to change { buffer.line_number }.from(1).to(nil)
      end
    end

    describe "#line" do
      before { buffer.lines = ["one", "two"] }

      it "returns the current line" do
        expect do
          client.command("normal j")
        end.to change { buffer.line }.from("one").to("two")
      end

      it "returns nil for inactive buffers" do
        client.command("new")
        expect(buffer.line).to eq(nil)
      end
    end

    describe "#line=" do
      it "updates the current line" do
        expect do
          buffer.line = "first"
        end.to change { buffer.line }.to("first")
      end
    end
  end
end
