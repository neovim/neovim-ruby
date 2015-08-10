require "helper"

module Neovim
  RSpec.describe Tabpage, :remote do
    let(:tabpage) { Tabpage.new(3, @client) }

    describe "Boolean return functions" do
      it "returns a boolean" do
        expect(tabpage.is_valid).to be(true)
      end
    end

    describe "Object return functions" do
      it "returns an object" do
        tabpage.set_var("v1", {"foo" => "bar"})
        expect(tabpage.get_var("v1")).to eq("foo" => "bar")
      end
    end

    describe "ArrayOf return functions" do
      it "returns an array" do
        expect(tabpage.get_windows).to respond_to(:to_ary)
      end
    end

    describe "Window return functions" do
      it "returns a window" do
        expect(tabpage.get_window).to be_a(Window)
      end
    end
  end
end
