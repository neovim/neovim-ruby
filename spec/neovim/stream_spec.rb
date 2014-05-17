require "helper"
require "neovim/stream"

module Neovim
  describe Stream do
    context "domain sockets" do
      let(:socket_path) { "/tmp/neovim.sock" }

      before do
        raise("Neovim isn't running on #{socket_path}") unless File.socket?(socket_path)
      end

      it "writes data and reads responses" do
        stream = Stream.new(socket_path, nil)
        stream.write("hello")
        stream.read.should respond_to(:to_str)
      end
    end
  end
end
