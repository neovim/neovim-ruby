require "helper"
require "neovim/ruby_provider/vim"

RSpec.describe Vim do
  around do |spec|
    client = Vim.instance_variable_get(:@__client)
    buffer_cache = Vim.instance_variable_get(:@__buffer_cache)
    curbuf = $curbuf
    curwin = $curwin

    begin
      Vim.__client = nil
      Vim.instance_variable_set(:@__buffer_cache, {})
      $curbuf = nil
      $curwin = nil

      spec.run
    ensure
      Vim.__client = client
      Vim.instance_variable_set(:@__buffer_cache, buffer_cache)
      $curbuf = curbuf
      $curwin = curwin
    end
  end

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
      expect(Vim).to receive(:__refresh_globals).with(client)
      expect(client).to receive(:foo).with(1, 2)

      Vim.__client = client
      Vim.foo(1, 2)
    end

    it "refreshes global variables" do
      client = Support.persistent_client
      client.command("vs foo")

      Vim.__client = client
      Vim.__refresh_globals(client)

      expect do
        Vim.command("wincmd n")
      end.to change { $curwin.index }.by(1)

      expect do
        Vim.command("vs bar")
      end.to change { $curbuf.index }.by(1)
    end
  end
end
