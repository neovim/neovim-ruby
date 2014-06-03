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
      it "returns a Cursor containing to the cursor position" do
        cursor = window.cursor
        expect(cursor).to be_a(Cursor)
        expect(cursor.line).to eq(1)
        expect(cursor.column).to eq(0)
      end
    end
  end
end
