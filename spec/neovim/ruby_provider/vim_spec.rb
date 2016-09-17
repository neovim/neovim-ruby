require "helper"
require "neovim/ruby_provider/vim"

RSpec.describe Vim do
  describe Vim::Buffer do
    it "refers to Neovim::Buffer" do
      expect(Vim::Buffer).to be(Neovim::Buffer)
    end
  end

  describe Vim::Window do
    it "refers to Neovim::Window" do
      expect(Vim::Window).to be(Neovim::Window)
    end
  end

  describe VIM do
    it "is an alias for the Vim module" do
      expect(VIM).to be(Vim)
    end
  end

  describe "#method_missing" do
    it "delegates method calls to @__client" do
      client = double(:client)
      expect(client).to receive(:foo).with(1, 2)

      Vim.__client = client
      Vim.foo(1, 2)
    end
  end
end
