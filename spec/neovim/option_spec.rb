require "helper"

module Neovim
  describe Option, :remote => true do
    let(:client) { Client.new("/tmp/neovim.sock") }

    shared_context "getters and setters" do
      it "reads a boolean option" do
        option = Option.new("hlsearch", scope, client)
        expect(option.value).to be_false
      end

      it "sets a boolean option" do
        option = Option.new("hlsearch", scope, client)
        option.value = false
        expect(option.value).to be_false
        expect(Option.new("hlsearch", scope, client).value).to be_false
      end

      it "reads a string option" do
        option = Option.new("shell", scope, client)
        expect(option.value).to eq("/bin/bash")
      end

      it "sets a string option" do
        option = Option.new("shell", scope, client)
        option.value = "/bin/zsh"
        expect(option.value).to eq("/bin/zsh")
        expect(Option.new("shell", scope, client).value).to eq("/bin/zsh")
      end

      it "raises an exception on invalid arguments" do
        option = Option.new("hlsearch", scope, client)
        expect {
          option.value = "what"
        }.to raise_error(Neovim::RPC::Error, /boolean/i)
      end
    end

    describe "globally scoped" do
      let(:scope) { Scope::Global.new }
      include_context "getters and setters"
    end

    describe "buffer scoped" do
      let(:scope) { Scope::Buffer.new(2) }
      include_context "getters and setters"
      before { pending "https://github.com/neovim/neovim/issues/796" }
    end
  end
end
