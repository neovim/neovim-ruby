require "helper"

module Neovim
  describe Window, :remote => true do
    let(:client) { Client.new("/tmp/neovim.sock") }
    let(:window) { Window.new(1, client) }

    describe "#buffer" do
      it "returns window's current buffer" do
        buffer = window.buffer
        expect(buffer).to be_a(Buffer)
        expect(buffer.index).to eq(2)
      end
    end

    describe "#cursor" do
      it "returns a Cursor containing the cursor position" do
        cursor = window.cursor
        expect(cursor).to be_a(Cursor)
        expect(cursor.line).to eq(1)
        expect(cursor.column).to eq(0)
      end
    end

    describe "#cursor=" do
      before do
        window.buffer.lines = ["first", "second", "third"]
      end

      it "sets the line and column number for the cursor" do
        expect {
          window.cursor = [2, 2]
        }.to change { [window.cursor.line, window.cursor.column] }.to([2, 2])
      end

      it "returns the new coordinates" do
        expect(window.cursor = [2, 2]).to eq([2, 2])
      end
    end
  end
end
