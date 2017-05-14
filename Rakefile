require "bundler/gem_tasks"
require "rspec/core/rake_task"

desc "Generate Neovim remote API docs"
task :docs do
  sh File.expand_path("../script/generate_docs", __FILE__)
end

desc "Dump nvim remote API"
task :api do
  sh File.expand_path("../script/dump_api", __FILE__)
end

desc "Initialize and update git submodules"
task :submodules do
  sh "git submodule update --init"
end

RSpec::Core::RakeTask.new(:spec)
task :default => [:submodules, :spec]
