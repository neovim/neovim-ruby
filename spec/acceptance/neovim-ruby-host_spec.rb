require "helper"

RSpec.describe "neovim-ruby-host" do
  it "loads and runs plugins from Ruby source files" do
    plugin1_path = Support.file_path("plugin1.rb")
    File.write(plugin1_path, <<-RUBY)
      Neovim.plugin do |plug|
        plug.function(:SyncAdd, :args => 2, :sync => true) do |nvim, x, y|
          x + y
        end

        plug.autocmd(:BufEnter, :pattern => "*.rb") do |nvim|
          nvim.current.line = "Ruby file, eh?"
        end
      end
    RUBY

    plugin2_path = Support.file_path("plugin2.rb")
    File.write(plugin2_path, <<-RUBY)
      Neovim.plugin do |plug|
        plug.command(:AsyncSetLine, :args => 1) do |nvim, str|
          nvim.current.line = str
        end
      end
    RUBY

    nvim = Neovim.attach_child(["--headless", "-u", "NONE", "-N", "-n"])

    host_exe = File.expand_path("../../../bin/neovim-ruby-host", __FILE__)
    nvim.command("let host = rpcstart('#{host_exe}', ['#{plugin1_path}', '#{plugin2_path}'])")

    expect(nvim.eval("rpcrequest(host, 'poll')")).to eq("ok")
    expect(nvim.eval("rpcrequest(host, '#{plugin1_path}:function:SyncAdd', [1, 2])")).to eq(3)

    expect {
      nvim.eval("rpcnotify(host, '#{plugin1_path}:autocmd:BufEnter:*.rb')")
    }.to change { nvim.current.buffer.lines.to_a }.from([""]).to(["Ruby file, eh?"])

    expect {
      nvim.eval("rpcnotify(host, '#{plugin2_path}:command:AsyncSetLine', ['foo'])")
    }.to change { nvim.current.buffer.lines.to_a }.from(["Ruby file, eh?"]).to(["foo"])

    expect {
      nvim.eval("rpcnotify(host, 'Unknown')")
    }.not_to raise_error

    expect {
      nvim.eval("call rpcrequest(host, 'Unknown')")
    }.to raise_error(ArgumentError)
  end
end
