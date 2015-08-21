require "fileutils"

module Support
  module Remote
    def with_neovim_client(connect)
      nvim = File.expand_path("../../vendor/neovim/build/bin/nvim", __FILE__)

      case connect.to_sym
      when :embed
        target = IO.popen("#{nvim} --embed -u NONE -i NONE -N -n", "rb+", :err => "/dev/null")
        nvim_pid = target.pid
      when :unix
        @listen_address = target = "/tmp/nvim.sock"
        FileUtils.rm_f(@listen_address)
        env = {"NVIM_LISTEN_ADDRESS" => @listen_address}
        nvim_pid = Process.spawn(env, "#{nvim} -u NONE -i NONE -N -n", :out => "/dev/null")

        loop { break if File.exists?(@listen_address) }
      when :tcp
        @listen_address = target = "127.0.0.1:3333"
        env = {"NVIM_LISTEN_ADDRESS" => @listen_address}
        nvim_pid = Process.spawn(env, "#{nvim} -u NONE -i NONE -N -n", :out => "/dev/null")

        begin
          wait_socket = TCPSocket.open("127.0.0.1", 3333)
        rescue Errno::ECONNREFUSED
          retry
        end

        wait_socket.close
      else
        raise "Can't spawn Neovim process of type #{connect.inspect}"
      end

      begin
        Timeout.timeout(1) do
          yield Neovim.connect(target)
        end
      ensure
        target.close if target.respond_to?(:close)
        Process.kill(:TERM, nvim_pid) rescue nil
        Process.waitpid(nvim_pid) rescue nil
      end
    end
  end
end
