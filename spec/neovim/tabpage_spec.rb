require "helper"

module Neovim
  RSpec.describe Tabpage do
    let(:tabpage) { Neovim.attach_child(["-n", "-u", "NONE"]).current.tabpage }

    describe "#respond_to?" do
      it "returns true for Tabpage functions" do
        expect(tabpage).to respond_to(:is_valid)
      end

      it "returns true for Ruby functions" do
        expect(tabpage).to respond_to(:inspect)
      end

      it "returns false otherwise" do
        expect(tabpage).not_to respond_to(:foobar)
      end
    end

    describe "#method_missing" do
      it "enables tabpage_* function calls" do
        expect(tabpage.is_valid).to be(true)
      end
    end
  end
end
