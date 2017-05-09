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
  desc "Run functional tests"
  RSpec::Core::RakeTask.new(:functional)

  desc "Run acceptance tests"
  task :acceptance => :submodules do
    sh File.expand_path("../script/acceptance_tests", __FILE__)
  end
end

task :spec => "spec:functional"
task :default => ["spec:acceptance", "spec:functional"]
