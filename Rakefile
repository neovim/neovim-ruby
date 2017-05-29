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

namespace :spec do
  desc "Run functional specs"
  RSpec::Core::RakeTask.new(:functional) do |t|
    t.exclude_pattern = "spec/integration_spec.rb,spec/integration/**/*"
  end

  desc "Run integration specs"
  RSpec::Core::RakeTask.new(:integration => :submodules) do |t|
    t.pattern = "spec/integration_spec.rb"
  end

  desc "Run all tests"
  RSpec::Core::RakeTask.new(:all => :submodules)
end

task :default => "spec:all"
