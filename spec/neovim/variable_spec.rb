require "helper"

module Neovim
  RSpec.describe Variable, :remote => true do
    shared_context "getters and setters" do
      it "reads a variable" do
        variable = Variable.new("buf_var", scope, @client)
        expect(variable.value).to be_nil
      end

      it "sets a variable" do
        variable = Variable.new("test_var", scope, @client)
        variable.value = "val"

        expect(variable.value).to eq("val")
        expect(Variable.new("test_var", scope, @client).value).to eq("val")
      end

      it "nullifies a variable" do
        variable = Variable.new("test_var", scope, @client)
        variable.value = "val"
        variable.value = nil

        expect(variable.value).to be_nil
        expect(Variable.new("test_var", scope, @client).value).to be_nil
      end
    end

    describe "globally scoped" do
      let(:scope) { Scope::Global.new }
      include_context "getters and setters"
    end

    describe "buffer scoped" do
      let(:buffer) { Buffer.new(2, @client) }
      let(:scope) { Scope::Buffer.new(buffer.to_msgpack) }
      include_context "getters and setters"
    end

    describe "window scoped" do
      let(:window) { Window.new(1, @client) }
      let(:scope) { Scope::Window.new(window.to_msgpack) }
      include_context "getters and setters"
    end

    describe "builtin scoped" do
      it "reads a variable" do
        scope = Scope::Builtin.new
        variable = Variable.new("beval_col", scope, @client)
        expect(variable.value).to eq(0)
      end

      it "raises an exception when trying to set a variable" do
        scope = Scope::Builtin.new
        variable = Variable.new("bevel_col", scope, @client)
        expect {
          variable.value = "val"
        }.to raise_error(Neovim::Scope::Error, /builtin/)
      end
    end
  end
end
