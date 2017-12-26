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

namespace :spec do
  desc "Run functional specs"
  RSpec::Core::RakeTask.new(:functional) do |t|
    t.exclude_pattern = "spec/acceptance_spec.rb,spec/acceptance/**/*"
  end

  desc "Run acceptance specs"
  RSpec::Core::RakeTask.new(:acceptance) do |t|
    t.pattern = "spec/acceptance_spec.rb"
    t.rspec_opts = "--format documentation"
  end
end

task default: ["spec:functional", "spec:acceptance"]
