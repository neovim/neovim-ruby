require "helper"

module Neovim
  RSpec.describe Current, :remote do
    let(:current) { Current.new(@client) }

    describe "#line" do
      it "returns an empty string if the current line is empty" do
        expect(current.line).to eq("")
      end

      it "returns the contents of the line" do
        current.line = "New content"
        expect(current.line).to eq("New content")
      end
    end

    describe "#line=" do
      it "sets the content of the current line" do
        current.line = "New content"
        expect(current.line).to eq("New content")
      end
    end

    describe "#buffer" do
      it "returns the current buffer" do
        expect(current.buffer).to be_a(Buffer)
      end
    end

    describe "#buffer=" do
      it "sets the current buffer" do
        initial_index = current.buffer.index
        @client.command("vnew")

        expect {
          current.buffer = initial_index
        }.to change { current.buffer.index }
      end
    end

    describe "#window" do
      it "returns the current window" do
        expect(current.window).to be_a(Window)
      end
    end

    describe "#window=" do
      it "sets the current window" do
        @client.command("vsp")
        expect(current.window.index).not_to eq(1)

        expect {
          current.window = 1
        }.to change { current.window.index }.to(1)
      end
    end

    describe "#tabpage" do
      it "returns the current tabpage" do
        expect(current.tabpage).to be_a(Tabpage)
      end
    end

    describe "#tabpage=" do
      it "sets the current tabpage" do
        initial_index = current.tabpage.index
        @client.command("tabnew")
        expect(current.tabpage.index).not_to eq(initial_index)

        expect {
          current.tabpage = initial_index
        }.to change { current.tabpage.index }.to(initial_index)
      end
    end
  end
end
