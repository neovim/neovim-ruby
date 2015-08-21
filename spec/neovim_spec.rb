require "helper"
require "socket"
require "fileutils"

RSpec.describe Neovim do
  describe ".connect", :remote do
    it "connects to a UNIX socket", :connect => :unix do
      expect(@client.strwidth("hi")).to eq(2)
    end

    it "connects to a TCP socket", :connect => :tcp do
      expect(@client.strwidth("hi")).to eq(2)
    end

    it "connects to an embedded process through standard streams", :connect => :embed do
      expect(@client.strwidth("hi")).to eq(2)
    end

    it "raises an exception otherwise" do
      expect {
        client = Neovim.connect("foobar")
      }.to raise_error(Neovim::InvalidAddress, /No such file or directory/)

      expect {
        client = Neovim.connect("127.0.0.1:80")
      }.to raise_error(Neovim::InvalidAddress, /Connection refused/)

      expect {
        client = Neovim.connect({})
      }.to raise_error(Neovim::InvalidAddress, /Can't connect to object/)
    end
  end
end
