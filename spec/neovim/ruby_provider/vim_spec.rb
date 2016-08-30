require "helper"
require "neovim/ruby_provider/vim"

RSpec.describe "the VIM module" do
  describe "VIM::Buffer" do
    it "refers to Neovim::Buffer" do
      expect(VIM::Buffer).to be(Neovim::Buffer)
    end
  end

  describe "VIM::Window" do
    it "refers to Neovim::Window" do
      expect(VIM::Window).to be(Neovim::Window)
    end
  end

  describe "#method_missing" do
    it "delegates method calls to @__client" do
      client = double(:client)
      expect(client).to receive(:foo).with(1, 2)

      VIM.__client = client
      VIM.foo(1, 2)
    end
  end
end
