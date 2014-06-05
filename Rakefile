require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)
task :default => :spec

namespace :neovim do
  desc "Pretty print the Neovim message pack API"
  task :api do
    require "neovim"
    require "msgpack"
    require "pp"

    stream = Neovim::Stream.new("/tmp/neovim.sock", nil)
    response = Neovim::RPC.new([0, 0, 0, []], stream).response
    pp MessagePack.unpack(response[3][1])
  end

  desc "Start a Neovim instance to run the test suite against"
  task :start do
    begin
      File.delete("/tmp/neovim.sock")
    rescue Errno::ENOENT
    end

    env = {"NEOVIM_LISTEN_ADDRESS" => "/tmp/neovim.sock"}

    loop do
      neovim_pid = spawn(env, "nvim -u NONE -N")
      _, status = Process.waitpid2(neovim_pid)
      break if status.exitstatus == 0
    end
  end

  desc "Update neovim installation to current master"
  task :update do
    sh "brew remove neovim && " +
       "brew install --HEAD https://raw.github.com/neovim/neovim/master/neovim.rb"
  end
end
