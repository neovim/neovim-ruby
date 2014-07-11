require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)
task :default => :spec

namespace :neovim do
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
    sh "which brew && " +
       "brew update && " +
       "brew install --HEAD neovim"
  end
end
