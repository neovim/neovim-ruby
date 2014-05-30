class Remote
  def initialize(socket_path)
    @socket_path = socket_path
  end

  def restart
    Process.kill(:USR1, pid("remote"))
  end

  def listen
    trap_signals

    env = {"NEOVIM_LISTEN_ADDRESS" => @socket_path}
    cmd = "redir! >#{pidfile("neovim")} | echo getpid() | redir END | set noswapfile"

    File.write(pidfile("remote"), $$.to_s)
    neovim_pid = spawn(env, "nvim -c '#{cmd}'")

    begin
      Process.wait(neovim_pid)
    rescue Errno::ECHILD
    end
  end

  def trap_signals
    trap(:USR1) {
      begin
        neovim_pid = pid("neovim")
        Process.kill(:KILL, neovim_pid)
        Process.wait(neovim_pid)
      rescue Errno::ECHILD
      end

      begin
        File.delete(@socket_path)
      rescue Errno::ENOENT
      end

      listen
    }
  end

  def pidfile(basename)
    File.expand_path("../../../tmp/#{basename}.pid", __FILE__)
  end

  def pid(basename)
    File.read(pidfile(basename)).to_i
  end
end
