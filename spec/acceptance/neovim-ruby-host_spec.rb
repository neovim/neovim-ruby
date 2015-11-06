require "helper"
require "tempfile"

RSpec.describe "neovim-ruby-host" do
  let(:lib_path)  { File.expand_path("../../../lib", __FILE__) }
  let(:bin_path)  { File.expand_path("../../../bin/neovim-ruby-host", __FILE__) }
  let(:nvim_path) { File.expand_path("../../../vendor/neovim/build/bin/nvim", __FILE__) }

  specify do
    plugin1 = Tempfile.open("plug1") do |f|
      f.write(<<-RUBY)
        Neovim.plugin do |plug|
          plug.command(:SyncAdd, :args => 2, :sync => true) do |nvim, x, y|
            x + y
          end
        end
      RUBY
      f.path
    end

    plugin2 = Tempfile.open("plug2") do |f|
      f.write(<<-RUBY)
        Neovim.plugin do |plug|
          plug.command(:AsyncSetLine, :args => 1) do |nvim, str|
            nvim.current.line = str
          end
        end
      RUBY
      f.path
    end

    output = Tempfile.new("output").tap(&:close).path
    host_nvim = Neovim.attach_child(["--headless", "-u", "NONE", "-N", "-n"])

    # Start the remote host
    host_nvim.command(%{let g:chan = rpcstart("#{bin_path}", ["#{plugin1}", "#{plugin2}"])})
    sleep 0.3 # TODO figure out if/why this is necessary

    # Make two requests to the synchronous SyncAdd method and store the results
    host_nvim.command(%{let g:res1 = rpcrequest(g:chan, "SyncAdd", 1, 2)})
    host_nvim.command(%{let g:res2 = rpcrequest(g:chan, "SyncAdd", 3, 4)})

    # Write the results to the buffer
    host_nvim.command("put =g:res1")
    host_nvim.command("put =g:res2")
    host_nvim.command("normal o")

    # Set the current line content twice via the AsyncSetLine method
    host_nvim.command(%{call rpcnotify(g:chan, "AsyncSetLine", "foo")})
    host_nvim.command(%{call rpcnotify(g:chan, "AsyncSetLine", "bar")})
    sleep 0.3

    # Save the contents of the buffer
    host_nvim.command("write! #{output}")

    expect(File.read(output)).to eq(<<-OUT)

3
7
bar
    OUT
  end
end
