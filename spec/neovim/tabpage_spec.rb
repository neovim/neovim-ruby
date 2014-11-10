require "helper"

module Neovim
  describe Tabpage, :remote => true do
    let(:tabpage) { Tabpage.new(3, @client) }

    describe "#windows" do
      it "returns a list of windows" do
        windows = tabpage.windows
        expect(windows.size).to eq(1)
        expect(windows.first).to be_a(Window)
      end
    end

    describe "#current_window" do
      it "returns the current window" do
        window = tabpage.current_window
        expect(window).to be_a(Window)
      end
    end

    describe "#variable" do
      it "reads a tabpage scoped variable" do
        variable = tabpage.variable("tp_var")

        expect(variable).to be_a(Variable)
        expect(variable.name).to eq("tp_var")
        expect(variable.scope).to be_a(Scope::Tabpage)
      end
    end

    describe "#valid?" do
      it "returns true" do
        expect(tabpage).to be_valid
      end

      it "returns false" do
        skip "I don't know what this means"
      end
    end
  end
end
