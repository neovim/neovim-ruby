require "helper"

module Neovim
  describe Option, :remote => true do
    let(:client) { Client.new("/tmp/neovim.sock") }

    shared_context "getters and setters" do
      it "reads an option" do
        option = Option.new(option_name, scope, client)
        expect(option.value).to be_false
      end

      it "sets an option" do
        option = Option.new(option_name, scope, client)
        option.value = false
        expect(option.value).to be_false
        expect(Option.new(option_name, scope, client).value).to be_false
      end

      it "raises an exception on invalid arguments" do
        option = Option.new(option_name, scope, client)
        expect {
          option.value = "what"
        }.to raise_error(Neovim::RPC::Error, /boolean/i)
      end
    end

    describe "globally scoped" do
      let(:scope) { Scope::Global.new }
      let(:option_name) { "hlsearch" }
      include_context "getters and setters"
    end

    describe "buffer scoped" do
      let(:scope) { Scope::Buffer.new(2) }
      let(:option_name) { "expandtab" }
      include_context "getters and setters"
    end
  end
end
