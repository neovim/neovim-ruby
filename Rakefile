require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)
task :default => :spec

RSpec::Core::RakeTask.new("spec:ci") do |t|
  t.rspec_opts = "--color --format documentation"

  begin
    Rake::Task["neovim:install"].invoke
  rescue
    puts "Neovim install failed, retrying"
    Rake::Task["neovim:install"].reenable
    Rake::Task["neovim:install"].invoke
  end
end

namespace :neovim do
  vendor = File.expand_path("../vendor/neovim", __FILE__)

  desc "Install Neovim"
  task :install do
    sh "git submodule update --init && " +
       "cd #{vendor} && " +
       "make distclean && " +
       "make"
  end

  desc "Update Neovim installation"
  task :update do
    sh "git submodule update --init && " +
       "cd #{vendor} && " +
       "make distclean && " +
       "git pull origin master && " +
       "make"
  end
end
