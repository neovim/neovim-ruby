begin
  require "helper"
rescue LoadError
end

RSpec.describe "Vim::Window", :embedded do
  before do
    $curbuf.set_lines(0, -1, true, ["one", "two", "three"])
    Vim.command("vsplit")
  end

  specify "$curwin" do
    expect($curwin).to be_a(Vim::Window)
  end

  specify ".current" do
    expect(Vim::Window.current).to eq($curwin)
  end

  specify ".[]" do
    expect(Vim::Window[0]).to eq($curwin)
  end

  specify ".count" do
    expect do
      Vim.command("split")
    end.to change { Vim::Window.count }.by(1)

    expect do
      Vim.command("tabnew")
    end.to change { Vim::Window.count }.to(1)
      .and change { Vim::Window[1] }.to(nil)
  end

  specify "#buffer" do
    expect($curwin.buffer).to eq($curbuf)
  end

  specify "#height", "#height=" do
    expect do
      $curwin.height -= 1
    end.to change { $curwin.height }.by(-1)
  end

  specify "#width", "#width=" do
    expect do
      $curwin.width -= 1
    end.to change { $curwin.width }.by(-1)
  end

  specify "#cursor", "#cursor=" do
    expect($curwin.cursor = [2, 0]).to eq([2, 0])
    expect($curwin.cursor).to eq([2, 0])
    expect($curwin.buffer.line).to eq("two")
  end
end
