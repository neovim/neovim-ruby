require "helper"

module Neovim
  RSpec.describe Window, :remote do
    let(:window) { Window.new(1, @client) }

    describe "void return functions" do
      it "returns self" do
        expect(window.set_height(100)).to be(window)
      end
    end

    describe "Boolean return functions" do
      it "returns a boolean" do
        expect(window.is_valid).to be(true)
      end
    end

    describe "Integer return functions" do
      it "returns an integer" do
        expect(window.get_width).to respond_to(:to_int)
      end
    end

    describe "Object return functions" do
      it "returns an object" do
        window.set_var("v1", {"foo" => "bar"})
        expect(window.get_var("v1")).to eq("foo" => "bar")
      end
    end

    describe "ArrayOf return functions" do
      it "returns an array" do
        expect(window.get_position).to respond_to(:to_ary)
      end
    end

    describe "Buffer return functions" do
      it "returns a buffer" do
        expect(window.get_buffer).to be_a(Buffer)
      end
    end

    describe "Tabpage return functions" do
      it "returns a tabpage" do
        expect(window.get_tabpage).to be_a(Tabpage)
      end
    end
  end
end
