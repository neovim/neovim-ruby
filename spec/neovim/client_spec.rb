require "helper"

module Neovim
  RSpec.describe Client do
    include Support::Remote

    around do |spec|
      with_neovim_client(:embed) do |client|
        @client = client
        spec.run
      end
    end

    describe "#respond_to?" do
      it "returns true for vim functions" do
        expect(@client).to respond_to(:strwidth)
      end

      it "returns true for non-vim functions" do
        expect(@client).to respond_to(:inspect)
      end

      it "returns false otherwise" do
        expect(@client).not_to respond_to(:foobar)
      end
    end

    describe "#method_missing" do
      it "enables vim_* function calls" do
        expect(@client.strwidth("hi")).to eq(2)
      end
    end

    describe "#current" do
      it "returns the target" do
        expect(@client.current.buffer).to be_a(Buffer)
        expect(@client.current.window).to be_a(Window)
        expect(@client.current.tabpage).to be_a(Tabpage)
      end
    end
  end
end
