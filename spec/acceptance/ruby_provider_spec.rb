require "helper"

RSpec.describe "ruby_provider" do
  let(:nvim) do
    Neovim.attach_child(["nvim", "--headless", "-u", "NONE", "-N", "-n"])
  end

  before do
    provider_path = Support.file_path("provider.rb")
    File.write(provider_path, "require 'neovim/ruby_provider'")
    host_exe = File.expand_path("../../../bin/neovim-ruby-host", __FILE__)
    nvim.current.buffer.lines = ["line1", "line2"]
    nvim.command("let host = rpcstart('#{host_exe}', ['#{provider_path}'])")
  end

  describe "ruby_execute" do
    it "runs ruby directly" do
      ruby = "VIM.command('let myvar = [1, 2]')".inspect
      nvim.eval("rpcrequest(host, 'ruby_execute', #{ruby})")
      expect(nvim.eval("g:myvar")).to eq([1, 2])
    end

    it "exposes the $curwin variable" do
      nvim.command("vsplit")

      expect {
        ruby = "$curwin.width -= 1".inspect
        nvim.eval("rpcrequest(host, 'ruby_execute', #{ruby})")
      }.to change { nvim.current.window.width }.by(-1)
    end

    it "exposes the $curbuf variable" do
      expect {
        ruby = "$curbuf.lines = ['line']".inspect
        nvim.eval("rpcrequest(host, 'ruby_execute', #{ruby})")
      }.to change { nvim.current.buffer.lines.to_a }.to(["line"])
    end
  end

  describe "ruby_execute_file" do
    let(:script_path) { Support.file_path("script.rb") }

    it "runs ruby from a file" do
      File.write(script_path, "VIM.command('let myvar = [1, 2]')")
      nvim.eval("rpcrequest(host, 'ruby_execute_file', '#{script_path}')")
      expect(nvim.eval("g:myvar")).to eq([1, 2])
    end

    it "exposes the $curwin variable" do
      File.write(script_path, "$curwin.width -= 1")
      nvim.command("vsplit")

      expect {
        nvim.eval("rpcrequest(host, 'ruby_execute_file', '#{script_path}')")
      }.to change { nvim.current.window.width }.by(-1)
    end

    it "exposes the $curbuf variable" do
      File.write(script_path, "$curbuf.lines = ['line']")

      expect {
        nvim.eval("rpcrequest(host, 'ruby_execute_file', '#{script_path}')")
      }.to change { nvim.current.buffer.lines.to_a }.to(["line"])
    end
  end

  describe "ruby_do_range" do
    it "mutates lines via the $_ variable" do
      nvim.current.buffer.lines = ["a", "b", "c", "d"]

      expect {
        nvim.eval("rpcrequest(host, 'ruby_do_range', 2, 3, '$_.upcase!; 42')")
      }.to change { nvim.current.buffer.lines.to_a }.to(["a", "B", "C", "d"])
    end
  end
end
