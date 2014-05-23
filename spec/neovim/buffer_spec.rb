require "helper"
require "neovim/buffer"
require "neovim/client"

module Neovim
  describe Buffer do
    let(:client) { Client.new(socket_path) }
    let(:buffer) { Buffer.new(2, client) } # I don't know why it has to be 2

    let(:socket_path) do
      ENV.fetch("NEOVIM_LISTEN_ADDRESS", "/tmp/neovim.sock")
    end

    before do
      unless File.socket?(socket_path)
        raise("Neovim isn't running. Run it with `NEOVIM_LISTEN_ADDRESS=#{socket_path} nvim`")
      end

      buffer.lines[0..-1] = []
    end

    describe "#length" do
      it "returns the length of the buffer" do
        expect(buffer.length).to eq(1)
      end
    end

    describe "#lines" do
      it "returns an enumerable of strings" do
        expect(buffer.lines.to_a).to eq([""])
      end

      it "can be mutated" do
        buffer.lines[0] = "first line"
        expect(buffer.lines.to_a).to eq(["first line"])
      end

      it "can be mutated using a slice" do
        buffer.lines[0..1] = ["first line", "second line"]
        expect(buffer.lines.to_a).to eq(["first line", "second line"])
      end
    end
  end
end
