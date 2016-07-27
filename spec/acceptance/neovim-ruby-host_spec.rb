require "helper"
require "pty"

RSpec.describe "neovim-ruby-host" do
  let(:host_exe) do
    File.expand_path("../../../bin/neovim-ruby-host", __FILE__)
  end

  it "prints the gem version" do
    ["--version", "-V"].each do |opt|
      expect {
        system(host_exe, opt)
      }.to output("#{Neovim::VERSION}\n").to_stdout_from_any_process
    end
  end

  it "fails when attached to a TTY" do
    yielded = false

    PTY.spawn(host_exe) do |rd, wr, pid|
      yielded = true
      expect(rd.gets).to match(/can't run.+interactively/i)

      _, status = Process.waitpid2(pid)
      expect(status.exitstatus).to be(1)
    end

    expect(yielded).to be(true)
  end

  it "loads and runs plugins from Ruby source files" do
    plugin_path = Support.file_path("plugin1.rb")
    File.write(plugin_path, <<-RUBY)
      Neovim.plugin do |plug|
        plug.command(:AsyncSetLine, :args => 1) do |nvim, str|
          nvim.current.line = str
        end

        plug.function(:SyncAdd, :args => 2, :sync => true) do |nvim, x, y|
          x + y
        end

        plug.autocmd(:BufEnter, :pattern => "*.rb") do |nvim|
          nvim.current.line = "Ruby file, eh?"
        end

        plug.rpc(:TopLevelAdd, :nargs => 2, :sync => true) do |nvim, x, y|
          x + y
        end
      end
    RUBY

    nvim = Neovim.attach_child(["nvim", "-u", "NONE", "-n"])

    nvim.command("let host = rpcstart('#{host_exe}', ['#{plugin_path}'])")

    expect(nvim.eval("rpcrequest(host, 'poll')")).to eq("ok")
    expect(nvim.eval("rpcrequest(host, '#{plugin_path}:function:SyncAdd', [1, 2])")).to eq(3)
    expect(nvim.eval("rpcrequest(host, 'TopLevelAdd', 1, 2)")).to eq(3)

    expect {
      nvim.command("call rpcnotify(host, '#{plugin_path}:autocmd:BufEnter:*.rb')")
      sleep 0.01
    }.to change { nvim.current.buffer.lines.to_a }.from([""]).to(["Ruby file, eh?"])

    expect {
      nvim.command("call rpcnotify(host, '#{plugin_path}:command:AsyncSetLine', ['foo'])")
      sleep 0.01
    }.to change { nvim.current.buffer.lines.to_a }.from(["Ruby file, eh?"]).to(["foo"])

    expect {
      nvim.command("call rpcnotify(host, 'Unknown')")
    }.not_to raise_error

    expect {
      nvim.command("call rpcrequest(host, 'Unknown')")
    }.to raise_error(ArgumentError)
  end
end
