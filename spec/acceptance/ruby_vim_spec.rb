begin
  require "helper"
rescue LoadError
end

RSpec.describe "Vim", :embedded do
  before do
    $curbuf.set_lines(0, -1, true, ["one", "two", "three"])
  end

  specify { expect(Vim).to be(VIM) }

  specify "class methods" do
    Vim.message(".")

    expect {
      Vim.set_option("makeprg", "rake")
    }.to change { Vim.evaluate("&makeprg") }.to("rake")

    expect {
      Vim.set_option("timeoutlen=0")
    }.to change { Vim.evaluate("&timeoutlen") }.to(0)

    Vim.command("let g:foo = 'bar'")
    expect(Vim.evaluate("g:foo")).to eq("bar")
  end
end
