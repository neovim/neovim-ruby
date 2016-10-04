require "helper"
require "neovim/ruby_provider/window_ext"

module Neovim
  RSpec.describe Window do
    let!(:nvim) do
      Neovim.attach_child(Support.child_argv).tap do |nvim|
        stub_const("::Vim", nvim)
      end
    end

    after { nvim.shutdown }

    describe ".current" do
      it "returns the current window from the global Vim client" do
        expect(Window.current).to eq(nvim.get_current_window)
      end
    end

    describe ".count" do
      it "returns the current window count from the global Vim client" do
        expect {
          nvim.command("new")
        }.to change { Window.count }.by(1)
      end

      it "only includes windows within a tabpage" do
        expect {
          nvim.command("tabnew")
        }.not_to change { Window.count }.from(1)
      end
    end

    describe ".[]" do
      it "returns the window at the given index" do
        expect {
          nvim.command("new")
        }.to change { Window[1] }.from(nil).to(kind_of(Window))
      end

      it "only includes windows within a tabpage" do
        nvim.command("new")

        expect {
          nvim.command("tabnew")
        }.to change { Window[1] }.from(kind_of(Window)).to(nil)
      end
    end
  end
end
