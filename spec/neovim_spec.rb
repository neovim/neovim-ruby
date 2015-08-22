require "helper"

RSpec.describe Neovim do
  describe ".connect" do
    include Support::Remote

    it "connects to a UNIX socket" do
      with_neovim(:unix) do |target|
        expect(Neovim.connect(target).strwidth("hi")).to eq(2)
      end
    end

    it "connects to a TCP socket" do
      with_neovim(:tcp) do |target|
        expect(Neovim.connect(target).strwidth("hi")).to eq(2)
      end
    end

    it "connects to an embedded process through standard streams" do
      with_neovim(:embed) do |target|
        expect(Neovim.connect(target).strwidth("hi")).to eq(2)
      end
    end

    it "raises an exception otherwise" do
      expect {
        Neovim.connect("foobar")
      }.to raise_error
    end
  end
end
