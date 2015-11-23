require "helper"
require "tmpdir"

RSpec.describe "neovim-ruby-host" do
  it "loads and runs plugins from Ruby source files" do
    Dir.mktmpdir do |pwd|
      Dir.chdir(pwd) do
        File.write("./plugin1.rb", <<-RUBY)
          Neovim.plugin do |plug|
            plug.command(:SyncAdd, :args => 2, :sync => true) do |nvim, x, y|
              x + y
            end
          end
        RUBY

        File.write("./plugin2.rb", <<-RUBY)
          Neovim.plugin do |plug|
            plug.command(:AsyncSetLine, :args => 1) do |nvim, str|
              nvim.current.line = str
            end
          end
        RUBY

        nvim = Neovim.attach_child(["--headless", "-u", "NONE", "-N", "-n"])

        # Start the remote host
        host_exe = File.expand_path("../../../bin/neovim-ruby-host", __FILE__)
        nvim.command(%{let host = rpcstart("#{host_exe}", ["./plugin1.rb", "./plugin2.rb"])})

        # Send a "poll" request
        expect(nvim.eval(%{rpcrequest(host, "poll")})).to eq("ok")

        # Make a request to the synchronous SyncAdd method and store the result
        nvim.command(%{let result = rpcrequest(host, "SyncAdd", 1, 2)})

        # Write the result to the buffer
        nvim.command("put =result")
        nvim.command("normal o")

        # Set the current line via the AsyncSetLine method
        nvim.command(%{call rpcnotify(host, "AsyncSetLine", "foo")})

        # Make an unknown notification
        expect {
          nvim.command(%{call rpcnotify(host, "Unknown")})
        }.not_to raise_error

        # Make an unknown request
        expect {
          nvim.command(%{call rpcrequest(host, "Unknown")})
        }.to raise_error(ArgumentError, /unknown request/i)

        # Assert the contents of the buffer
        expect(nvim.current.buffer.lines).to eq(["", "3", "foo"])
      end
    end
  end
end
