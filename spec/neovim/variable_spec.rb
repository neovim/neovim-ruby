require "helper"
require "neovim/client"

module Neovim
  describe Variable do
    let(:client) { Client.new(socket_path) }

    let(:socket_path) do
      ENV.fetch("NEOVIM_LISTEN_ADDRESS", "/tmp/neovim.sock")
    end

    before do
      unless File.socket?(socket_path)
        raise("Neovim isn't running. Run it with `NEOVIM_LISTEN_ADDRESS=#{socket_path} nvim`")
      end
    end

    it "sets a global variable" do
      variable = Variable.new("g:test_var", client)
      variable.value = "val"

      expect(variable.value).to eq("val")
      expect(client.variable("g:test_var").value).to eq("val")
      expect(client.variable("test_var").value).to eq("val")
    end

    it "nullifies a global variable" do
      variable = Variable.new("g:test_var", client)
      variable.value = "val"
      variable.value = nil

      expect(variable.value).to be_nil
      expect(client.variable("g:test_var").value).to be_nil
      expect(client.variable("test_var").value).to be_nil
    end

    it "reads a builtin variable" do
      variable = Variable.new("v:beval_col", client)
      expect(variable.value).to eq(0)
    end

    it "raises an exception when trying to set a builtin variable" do
      variable = Variable.new("v:bevel_col", client)
      expect {
        variable.value = "val"
      }.to raise_error(Neovim::Variable::Scope::Error, /builtin/)
    end
  end
end
