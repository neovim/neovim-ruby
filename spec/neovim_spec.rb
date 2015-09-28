require "helper"

RSpec.describe Neovim do
  describe ".attach" do
    include Support::Remote

    it "connects to a TCP socket" do
      with_neovim(:tcp, "0.0.0.0:3333") do
        nvim = Neovim.attach_tcp("0.0.0.0", 3333)
        expect(nvim.strwidth("hi")).to eq(2)
      end
    end

    it "connects to a UNIX socket" do
      with_neovim(:unix, "/tmp/nvim.sock") do |target|
        nvim = Neovim.attach_unix("/tmp/nvim.sock")
        expect(nvim.strwidth("hi")).to eq(2)
      end
    end

    it "connects to a child through standard streams" do
      nvim = Neovim.attach_child(["-u", "NONE"])
      expect(nvim.strwidth("hi")).to eq(2)
    end
  end
end
