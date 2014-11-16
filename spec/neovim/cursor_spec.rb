require "helper"

module Neovim
  RSpec.describe Cursor, :remote do
    let(:window) { Window.new(1, @client) }
    let(:cursor) { Cursor.new(window, @client) }

    before do
      window.buffer.lines = ["first", "second", "third"]
    end

    describe "#line=" do
      it "moves the cursor to the provided line" do
        cursor.line = 2
        expect(cursor.line).to eq(2)
        expect(window.cursor.line).to eq(2)
      end

      it "fails to move the cursor to an out of range line" do
        expect {
          cursor.line = 50
        }.to raise_error(RPC::Error, /outside buffer/i)
      end

      it "returns the new line" do
        expect(cursor.line = 2).to eq(2)
      end
    end

    describe "#column=" do
      it "moves the cursor to the provided column" do
        cursor.column = 2
        expect(cursor.column).to eq(2)
        expect(window.cursor.column).to eq(2)
      end

      it "moves the cursor to the highest possible column" do
        cursor.column = 50
        expect(cursor.column).to eq("first".size - 1)
        expect(window.cursor.column).to eq("first".size - 1)
      end

      it "returns the new column" do
        expect(cursor.column = 50).to eq(50)
      end
    end
  end
end
