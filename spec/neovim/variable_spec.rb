require "helper"
require "neovim/client"
require "neovim/buffer"
require "neovim/scope"
require "neovim/variable"

module Neovim
  describe Variable, :remote => true do
    let(:client) { Client.new("/tmp/neovim.sock") }

    it "reads a global variable" do
      scope = Scope::Global.new
      variable = Variable.new("buf_var", scope, client)
      expect(variable.value).to be_nil
    end

    it "sets a global variable" do
      scope = Scope::Global.new
      variable = Variable.new("test_var", scope, client)
      variable.value = "val"

      expect(variable.value).to eq("val")
      expect(client.variable("test_var").value).to eq("val")
    end

    it "nullifies a global variable" do
      scope = Scope::Global.new
      variable = Variable.new("test_var", scope, client)
      variable.value = "val"
      variable.value = nil

      expect(variable.value).to be_nil
      expect(client.variable("test_var").value).to be_nil
    end

    it "reads a buffer variable" do
      scope = Scope::Buffer.new(1)
      variable = Variable.new("buf_var", scope, client)
      expect(variable.value).to be_nil
    end

    it "sets a buffer variable" do
      scope = Scope::Buffer.new(2)
      variable = Variable.new("buf_var", scope, client)
      buffer = Buffer.new(2, client)

      variable.value = "val"

      expect(variable.value).to eq("val")
      expect(buffer.variable("buf_var").value).to eq("val")
    end

    it "reads a builtin variable" do
      scope = Scope::Builtin.new
      variable = Variable.new("beval_col", scope, client)
      expect(variable.value).to eq(0)
    end

    it "raises an exception when trying to set a builtin variable" do
      scope = Scope::Builtin.new
      variable = Variable.new("bevel_col", scope, client)
      expect {
        variable.value = "val"
      }.to raise_error(Neovim::Scope::Error, /builtin/)
    end
  end
end
