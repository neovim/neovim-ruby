require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)
task :default => :spec

vendor = File.expand_path("../vendor/neovim", __FILE__)

namespace :neovim do
  desc "Start a Neovim instance to run the test suite against"
  task :start do
    begin
      File.delete("/tmp/neovim.sock")
    rescue Errno::ENOENT
    end

    env = {"NEOVIM_LISTEN_ADDRESS" => "/tmp/neovim.sock"}
    bin = File.join(vendor, "build/bin/nvim")

    loop do
      neovim_pid = spawn(env, "#{bin} -u NONE -i NONE -N")
      _, status = Process.waitpid2(neovim_pid)
      break if status.exitstatus == 0
    end
  end

  desc "Install neovim"
  task :install do
    sh "git submodule update && " +
       "cd #{vendor} && " +
       "make"
  end

  desc "Update neovim installation"
  task :update do
    sh "git submodule update && " +
       "git submodule sync && " +
       "cd #{vendor} && " +
       "rm -rf build && " +
       "make"
  end
end
