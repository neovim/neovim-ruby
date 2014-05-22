require "helper"
require "neovim/client"

module Neovim
  describe Client do
    let(:socket_path) do
      ENV.fetch("NEOVIM_LISTEN_ADDRESS", "/tmp/neovim.sock")
    end

    before do
      unless File.socket?(socket_path)
        raise("Neovim isn't running. Run it with `NEOVIM_LISTEN_ADDRESS=#{socket_path} nvim`")
      end
    end

    describe "#message" do
      it "prints a message to neovim" do
        pending "Nothing is in place to allow us to test this yet"
      end

      it "returns nil on success" do
        client = Client.new(socket_path)
        expect(client.message("test\n")).to be_nil
      end
    end

    describe "#set_option" do
      it "sets the provided option" do
        pending "Nothing is in place to allow us to test this yet"
      end

      it "returns nil on success" do
        client = Client.new(socket_path)
        expect(client.set_option("background", "light")).to be_nil
      end
    end

    describe "#command" do
      it "runs the provided command" do
        pending "Nothing is in place to allow us to test this yet"
      end

      it "returns nil on success" do
        client = Client.new(socket_path)
        expect(client.command('echo "Hello"')).to be_nil
      end
    end

    describe "#evaluate" do
      it "evaluates the vim expression" do
        pending "Nothing is in place to allow us to test this yet"
      end

      it "returns nil on success" do
        pending "raises 'Segmentation fault: 11'"

        client = Client.new(socket_path)
        expect(client.evaluate("ihello")).to be_nil
      end
    end
  end
end
