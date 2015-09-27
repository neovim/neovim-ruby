require "helper"

RSpec.describe Neovim do
  describe ".attach" do
    include Support::Remote

    it "connects to a TCP socket" do
      with_neovim(:tcp, "0.0.0.0:3333") do
        nvim = Neovim.attach("0.0.0.0:3333")
        expect(nvim.strwidth("hi")).to eq(2)
      end
    end

    it "connects to a UNIX socket" do
      with_neovim(:unix, "/tmp/nvim.sock") do |target|
        nvim = Neovim.attach("/tmp/nvim.sock")
        expect(nvim.strwidth("hi")).to eq(2)
      end
    end

    it "connects to an embedded process through standard streams" do
      pending "Not implemented"

      with_neovim(:embed) do |target|
        expect(Neovim.attach(target).strwidth("hi")).to eq(2)
      end
    end

    it "raises an exception otherwise" do
      expect {
        Neovim.attach("foobar")
      }.to raise_error(RuntimeError, /no connection/)
    end
  end
end
