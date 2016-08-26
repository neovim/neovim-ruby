require "helper"
require "neovim/ruby_provider/window_ext"

module Neovim
  RSpec.describe Window do
    let!(:nvim) do
      Neovim.attach_child(["nvim", "-i", "NONE", "-u", "NONE", "-n"]).tap do |nvim|
        stub_const("::VIM", nvim)
      end
    end

    after { nvim.shutdown }

    describe ".current" do
      it "returns the current window from the global VIM client" do
        expect(Window.current).to eq(nvim.get_current_window)
      end
    end

    describe ".count" do
      it "returns the current window count from the global VIM client" do
        expect {
          nvim.command("new")
        }.to change { Window.count }.by(1)
      end
    end

    describe ".[]" do
      it "returns the window from the global VIM client at the given index" do
        expect(Window[0]).to eq(nvim.get_current_window)
        nvim.command("tabnew")
        expect(Window[1]).to eq(nvim.get_current_window)
      end
    end
  end
end
