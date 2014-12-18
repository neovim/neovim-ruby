require "helper"

module Neovim
  RSpec.describe Buffer, :remote do
    let(:buffer) { Buffer.new(2, @client) } # I don't know why it has to be 2

    describe "void return functions" do
      it "returns self" do
        expect(buffer.set_line(0, "hello")).to be(buffer)
      end
    end

    describe "Boolean return functions" do
      it "returns a boolean" do
        expect(buffer.is_valid).to be(true)
      end
    end

    describe "String return functions" do
      it "returns a string" do
        expect(buffer.get_line(0)).to respond_to(:to_str)
      end
    end

    describe "Integer return functions" do
      it "returns an integer" do
        expect(buffer.get_number).to respond_to(:to_int)
      end
    end

    describe "Object return functions" do
      it "returns an object" do
        buffer.set_var("v1", {"foo" => "bar"})
        expect(buffer.get_var("v1")).to eq("foo" => "bar")
      end
    end

    describe "ArrayOf return functions" do
      it "returns an array" do
        expect(buffer.get_mark("m")).to respond_to(:to_ary)
      end
    end
  end
end
