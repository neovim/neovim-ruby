require "helper"

module Neovim
  RSpec.describe Client do
    let(:client) { Support.persistent_client }

    describe "#set_option" do
      it "sets an option from two arguments" do
        expect do
          client.set_option("makeprg", "rake")
        end.to change { client.evaluate("&makeprg") }.to("rake")
      end

      it "sets an option from a string" do
        expect do
          client.set_option("timeoutlen=0")
        end.to change { client.evaluate("&timeoutlen") }.to(0)
      end

      it "sets a boolean option" do
        expect do
          client.set_option("expandtab")
        end.to change { client.evaluate("&expandtab") }.to(1)
      end
    end

    describe "#shutdown" do
      it "causes nvim to exit" do
        client = Neovim.attach_child(Support.child_argv)
        client.shutdown
        expect { client.strwidth("hi") }.to raise_error(Neovim::Session::Disconnected)
      end
    end

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
      it "enables nvim_* function calls" do
        expect(client.strwidth("hi")).to eq(2)
      end

      it "raises exceptions for unknown methods" do
        expect do
          client.foobar
        end.to raise_error(NoMethodError)
      end

      it "raises exceptions for incorrect usage" do
        expect do
          client.strwidth("too", "many")
        end.to raise_error("Wrong number of arguments: expecting 1 but got 2")
      end
    end

    describe "#methods" do
      it "includes builtin methods" do
        expect(client.methods).to include(:inspect)
      end

      it "includes api methods" do
        expect(client.methods).to include(:strwidth)
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
