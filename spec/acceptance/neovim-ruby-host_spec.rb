require "helper"
require "tmpdir"

RSpec.describe "neovim-ruby-host" do
  specify do
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
        sleep 0.5 # TODO figure out if/why this is necessary

        # Make a request to the synchronous SyncAdd method and store the results
        nvim.command(%{let result = rpcrequest(host, "SyncAdd", 1, 2)})

        # Write the results to the buffer
        nvim.command("put =result")
        nvim.command("normal o")

        # Set the current line content via the AsyncSetLine method
        nvim.command(%{call rpcnotify(host, "AsyncSetLine", "foo")})

        # Wait for notification to be received
        sleep 0.2

        # Save the contents of the buffer
        nvim.command("write! ./output")

        expect(File.read("./output")).to eq("\n3\nfoo\n")
      end
    end
  end
end
