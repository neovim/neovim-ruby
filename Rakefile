require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)
task :default => :spec

desc "Generate Neovim remote API docs"
task :docs do
  sh File.expand_path("../bin/generate_docs", __FILE__)
end
