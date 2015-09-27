require "fileutils"

module Support
  module Remote
    def with_neovim_client(connect)
      with_neovim(connect) do |target|
        yield Neovim.connect(target)
      end
    end

    def with_neovim_connection(connect)
      with_neovim(connect) do |target|
        yield Neovim::Connection.parse(target).to_io
      end
    end

    def with_neovim(connect, target=nil)
      nvim_path = File.expand_path("../../vendor/neovim/build/bin/nvim", __FILE__)

      case connect.to_sym
      when :embed
        nvim_pid, target = start_neovim_embed(nvim_path)
      when :unix
        nvim_pid, target = start_neovim_unix(nvim_path, target=nil)
      when :tcp
        nvim_pid, target = start_neovim_tcp(nvim_path, target=nil)
      else
        raise "Can't spawn Neovim process of type #{connect.inspect}"
      end

      begin
        result = yield target
      ensure
        begin
          Process.kill(:TERM, nvim_pid)
          Process.waitpid(nvim_pid)
        rescue Errno::ESRCH, Errno::ECHILD
        end
      end
      result
    end

    private

    def start_neovim_embed(nvim_path)
      target = IO.popen("#{nvim_path} --embed -u NONE -i NONE -N -n", "rb+", :err => "/dev/null")
      [target.pid, target]
    end

    def start_neovim_unix(nvim_path, listen_address)
      listen_address ||= "/tmp/nvim.sock"
      FileUtils.rm_f(listen_address)
      env = {"NVIM_LISTEN_ADDRESS" => listen_address}
      pid = Process.spawn(env, "#{nvim_path} -u NONE -i NONE -N -n", :out => "/dev/null")

      loop { break if File.exists?(listen_address) }
      [pid, listen_address]
    end

    def start_neovim_tcp(nvim_path, listen_address)
      listen_address ||= "127.0.0.1:3333"
      env = {"NVIM_LISTEN_ADDRESS" => listen_address}
      pid = Process.spawn(env, "#{nvim_path} -u NONE -i NONE -N -n", :out => "/dev/null")

      begin
        wait_socket = TCPSocket.open("127.0.0.1", 3333)
      rescue Errno::ECONNREFUSED
        retry
      end
      wait_socket.close
      [pid, listen_address]
    end
  end
end
