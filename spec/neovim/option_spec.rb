require "helper"
require "neovim/client"
require "neovim/option"

module Neovim
  describe Option do
    let(:client) { Client.new(socket_path) }

    let(:socket_path) do
      ENV.fetch("NEOVIM_LISTEN_ADDRESS", "/tmp/neovim.sock")
    end

    before do
      unless File.socket?(socket_path)
        raise("Neovim isn't running. Run it with `NEOVIM_LISTEN_ADDRESS=#{socket_path} nvim`")
      end
      Option.new("hlsearch", client).value = true
      Option.new("shell", client).value = "/bin/bash"
    end

    it "returns the value of a boolean option" do
      option = Option.new("hlsearch", client)
      expect(option.value).to eq(true)
    end

    it "changes the value of a boolean option" do
      option = Option.new("hlsearch", client)
      option.value = false
      expect(option.value).to eq(false)
      expect(client.option("hlsearch").value).to eq(false)
    end

    it "returns the value of a string option" do
      option = Option.new("shell", client)
      expect(option.value).to eq("/bin/bash")
    end

    it "changes the value of a string option" do
      option = Option.new("shell", client)
      option.value = "/bin/zsh"
      expect(option.value).to eq("/bin/zsh")
    end

    it "raises an exception on invalid arguments" do
      option = Option.new("hlsearch", client)
      expect {
        option.value = "what"
      }.to raise_error(Neovim::RPC::Error, /boolean/i)
    end
  end
end
