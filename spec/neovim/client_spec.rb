require "helper"

module Neovim
  RSpec.describe Client do
    let(:client) { Neovim.attach_child(["-u", "NONE"]) }

    describe "#respond_to?" do
      it "returns true for vim functions" do
        expect(client).to respond_to(:strwidth)
      end

      it "returns true for Ruby functions" do
        expect(client).to respond_to(:inspect)
      end

      it "returns false otherwise" do
        expect(client).not_to respond_to(:foobar)
      end
    end

    describe "#method_missing" do
      it "enables vim_* function calls" do
        expect(client.strwidth("hi")).to eq(2)
      end

      it "raises exceptions for unknown methods" do
        expect {
          client.foobar
        }.to raise_error(NoMethodError)
      end

      it "raises exceptions for incorrect usage" do
        expect {
          client.strwidth("too", "many")
        }.to raise_error("Wrong number of arguments: expecting 1 but got 2")
      end
    end

    describe "#current" do
      it "returns the target" do
        expect(client.current.buffer).to be_a(Buffer)
        expect(client.current.window).to be_a(Window)
        expect(client.current.tabpage).to be_a(Tabpage)
      end
    end
  end
end
