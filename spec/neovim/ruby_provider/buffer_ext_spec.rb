require "helper"
require "neovim/ruby_provider/buffer_ext"

module Neovim
  RSpec.describe Buffer do
    let!(:nvim) do
      Neovim.attach_child(["nvim", "-i", "NONE", "-u", "NONE", "-n"]).tap do |nvim|
        stub_const("::VIM", nvim)
      end
    end

    after { nvim.shutdown }

    describe ".current" do
      it "returns the current buffer from the global VIM client" do
        expect(Buffer.current).to eq(nvim.get_current_buffer)
      end
    end

    describe ".count" do
      it "returns the current buffer count from the global VIM client" do
        expect {
          nvim.command("new")
        }.to change { Buffer.count }.by(1)
      end
    end

    describe ".[]" do
      it "returns the buffer from the global VIM client at the given index" do
        expect(Buffer[0]).to eq(nvim.get_current_buffer)
        nvim.command("new")
        expect(Buffer[1]).to eq(nvim.get_current_buffer)
      end
    end
  end
end
