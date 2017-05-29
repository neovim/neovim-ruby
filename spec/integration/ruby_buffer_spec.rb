begin
  require "helper"
rescue LoadError
end

RSpec.describe "Vim::Buffer", :embedded do
  before do
    $curbuf.set_lines(0, -1, true, ["one", "two", "three"])
    $curwin.set_cursor([1, 0])
  end

  specify "$curbuf" do
    expect($curbuf).to be_a(Vim::Buffer)
  end

  specify ".current" do
    expect(Vim::Buffer.current).to eq($curbuf)
  end

  specify ".[]" do
    expect(Vim::Buffer[0]).to eq($curbuf)
  end

  specify ".count" do
    expect(Vim::Buffer.count).to be > 0
  end

  specify "#name" do
    $curbuf.set_name("test_buf")
    expect($curbuf.name).to include("test_buf")
  end

  specify "#number" do
    expect($curbuf.number).to eq(1)
  end

  specify "#count" do
    expect($curbuf.count).to eq(3)
  end

  specify "#length" do
    expect($curbuf.length).to eq(3)
  end

  specify "#[]" do
    expect($curbuf[1]).to eq("one")

    expect do
      $curbuf[-1]
    end.to raise_error(/out of bounds/)

    expect do
      $curbuf[4]
    end.to raise_error(/out of bounds/)
  end

  specify "#[]=" do
    expect($curbuf[1] = "first").to eq("first")
    expect($curbuf[1]).to eq("first")

    expect do
      $curbuf[4] = "line"
    end.to raise_error(/out of bounds/)

    expect do
      $curbuf[-1] = "line"
    end.to raise_error(/out of bounds/)
  end

  specify "#delete" do
    expect($curbuf.delete(3)).to eq(nil)
    expect($curbuf.count).to eq(2)

    expect do
      $curbuf.delete(-1)
    end.to raise_error(/out of bounds/)

    expect do
      $curbuf.delete(4)
    end.to raise_error(/out of bounds/)
  end

  specify "#append" do
    expect($curbuf.append(2, "last")).to eq("last")
    expect($curbuf[3]).to eq("last")

    $curbuf.set_lines(0, -1, true, [])
    $curbuf.append(0, "one")

    expect($curbuf.lines.to_a).to eq(["one", ""])

    expect do
      $curbuf.append(0, "two")
    end.not_to change { $curwin.cursor }

    expect do
      $curbuf.append(-1, "line")
    end.to raise_error(/out of bounds/)

    expect do
      $curbuf.append(4, "line")
    end.to raise_error(/out of bounds/)
  end

  specify "#line_number" do
    expect do
      Vim.command("normal j")
    end.to change { $curbuf.line_number }.from(1).to(2)

    original = $curbuf

    begin
      Vim.command("new")
      expect(original.line_number).to eq(nil)
    ensure
      Vim.set_current_buf(original)
    end
  end

  specify "#line" do
    expect do
      Vim.command("normal j")
    end.to change { $curbuf.line }.from("one").to("two")

    original = $curbuf

    begin
      Vim.command("new")
      expect(original.line).to eq(nil)
    ensure
      Vim.set_current_buf(original)
    end
  end

  specify "#line=" do
    $curbuf.line = "first"
    expect($curbuf[1]).to eq("first")

    original = $curbuf

    begin
      Vim.command("new")

      expect do
        original.line = "line"
      end.not_to change { original.lines.to_a }
    ensure
      Vim.set_current_buf(original)
    end
  end
end
