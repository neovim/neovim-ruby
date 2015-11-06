require "timeout"
require "tempfile"

RSpec.describe "neovim-ruby-host" do
  let(:lib_path)  { File.expand_path("../../../lib", __FILE__) }
  let(:bin_path)  { File.expand_path("../../../bin/neovim-ruby-host", __FILE__) }
  let(:nvim_path) { File.expand_path("../../../vendor/neovim/build/bin/nvim", __FILE__) }

  specify do
    pending "TODO: Notifications are broken in this test"

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

    nvim_pid = spawn({"RUBYLIB" => lib_path}, <<-BASH, [:out, :err] => "/dev/null")
      #{nvim_path} \
        --headless -u NONE -N -n \
        +'let g:chan = rpcstart("#{bin_path}", ["#{plugin1}", "#{plugin2}"])' \
        +'sleep 300m' \
        +'let g:res = rpcrequest(g:chan, "SyncAdd", 1, 2)' \
        +'put =g:res' \
        +'normal o' \
        +'call rpcnotify(g:chan, "AsyncSetLine", "Foobar")' \
        +'sleep 300m' \
        +'write! #{output}' \
        +'quitall!'
    BASH

    begin
      Timeout.timeout(5) do
        _, status = ::Process.waitpid2(nvim_pid)
        expect(status.exitstatus).to be(0)
        expect(File.read(output)).to eq(<<-OUT)

3
Foobar
        OUT
      end
    ensure
      ::Process.kill(:TERM, nvim_pid) rescue nil
    end
  end
end
