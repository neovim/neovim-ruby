require "helper"
require "neovim/ruby_provider/window_ext"

module Neovim
  RSpec.describe Window do
    let!(:nvim) do
      Support.persistent_client.tap do |client|
        stub_const("::Vim", client)
      end
    end

    describe ".current" do
      it "returns the current window from the global Vim client" do
        expect(Window.current).to eq(nvim.get_current_win)
      end
    end

    describe ".count" do
      it "returns the current window count from the global Vim client" do
        expect do
          nvim.command("new")
        end.to change { Window.count }.by(1)
      end

      it "only includes windows within a tabpage" do
        expect do
          nvim.command("tabnew")
        end.not_to change { Window.count }.from(1)
      end
    end

    describe ".[]" do
      it "returns the window at the given index" do
        window = Window[0]

        expect(window).to be_a(Window)
        expect(window).to eq(nvim.list_wins[0])
      end

      it "only includes windows within a tabpage" do
        expect do
          nvim.command("tabnew")
        end.to change { Window[0] }
      end
    end
  end
end
