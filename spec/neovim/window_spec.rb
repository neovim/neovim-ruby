require "helper"

module Neovim
  RSpec.describe Window, :remote do
    let(:window) { Window.new(1, @client) }

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

    describe "height" do
      it "returns the current height" do
        expect(window.height).to be > 0
      end
    end

    describe "height=" do
      it "sets the window height" do
        expect {
          window.height -= 1
        }.to change { window.height }.by(-1)
      end

      it "returns the new height" do
        new_height = window.height - 2
        expect(window.height -= 2).to eq(new_height)
      end
    end

    describe "width" do
      it "returns the current width" do
        expect(window.width).to be > 0
      end
    end

    describe "width=" do
      before { @client.command("vsp") }

      it "sets the window width" do
        expect {
          window.width += 1
        }.to change { window.width }.by(1)
      end

      it "returns the new width" do
        new_width = window.width - 2
        expect(window.width -= 2).to eq(new_width)
      end
    end

    describe "#variable" do
      it "reads a window scoped variable" do
        variable = window.variable("win_var")

        expect(variable).to be_a(Variable)
        expect(variable.name).to eq("win_var")
        expect(variable.scope).to be_a(Scope::Window)
      end
    end

    describe "#option" do
      it "reads a window scoped option" do
        option = window.option("list")

        expect(option).to be_an(Option)
        expect(option.name).to eq("list")
        expect(option.scope).to be_a(Scope::Window)
      end
    end

    describe "#position" do
      it "returns the cursor position" do
        expect(window.position).to eq([0, 0])
        @client.command("vsp")

        expect(window.position[0]).to eq(0)
        expect(window.position[1]).to be > 0
      end
    end

    describe "#tabpage" do
      it "returns the tabpage the buffer is in" do
        expect(window.tabpage).to be_a(Tabpage)
        expect(window.tabpage.current_window).to eq(window)
      end
    end

    describe "#valid?" do
      it "returns true" do
        expect(window).to be_valid
      end

      it "returns false" do
        skip "I don't know what this means"
      end
    end
  end
end
