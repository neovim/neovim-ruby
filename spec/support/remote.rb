class Remote
  def initialize(socket_path)
    @socket_path = socket_path
  end

  def restart
    Process.kill(:USR1, pid("remote"))
    Process.wait(pid("neovim"))
  rescue Errno::ECHILD
  end

  def shutdown
    Process.kill(:TERM, pid("remote"))
    Process.wait(pid("remote"))
  rescue Errno::ECHILD
  end

  def listen
    trap_signals

    env = {"NEOVIM_LISTEN_ADDRESS" => @socket_path}
    cmd = "redir! >#{pidfile("neovim")} | echo getpid() | redir END"

    File.write(pidfile("remote"), $$.to_s)
    neovim_pid = spawn(env, "nvim -c '#{cmd}'")
    Process.wait(neovim_pid)
  end

  def trap_signals
    trap(:USR1) {
      Process.kill(:KILL, pid("neovim"))
      File.delete(@socket_path)

      listen
    }

    trap(:TERM) {
      Process.kill(:KILL, pid("neovim"))
      File.delete(@socket_path)
    }
  end

  def pidfile(basename)
    File.expand_path("../../../tmp/#{basename}.pid", __FILE__)
  end

  def pid(basename)
    File.read(pidfile(basename)).to_i
  end
end
