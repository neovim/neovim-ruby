module Support
  module Remote
    def with_neovim_client
      nvim = File.expand_path("../../vendor/neovim/build/bin/nvim", __FILE__)

      IO.popen("#{nvim} --embed -u NONE -i NONE -N -n", "rb+", :err => "/dev/null") do |io|
        nvim_pid = io.pid

        begin
          Timeout.timeout(1) do
            yield Neovim::Client.new(io)
          end
        ensure
          Process.kill(:TERM, nvim_pid)
          Process.waitpid2(nvim_pid)
        end
      end
    end
  end
end
