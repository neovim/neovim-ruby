require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)
task :default => :spec

desc "Run tests for CI"
task :ci do
  begin
    Rake::Task["neovim:install"].invoke
  rescue
    # retry since the install fails occassionally
    Rake::Task["neovim:install"].invoke
  end

  Rake::Task[:spec].invoke
end

namespace :neovim do
  vendor = File.expand_path("../vendor/neovim", __FILE__)

  desc "Install Neovim"
  task :install do
    sh "git submodule update --init && " +
       "cd #{vendor} && " +
       "make"
  end

  desc "Update Neovim installation"
  task :update do
    sh "git submodule update --init && " +
       "cd #{vendor} && " +
       "git clean -fdx && " +
       "git pull origin master && " +
       "make"
  end
end
