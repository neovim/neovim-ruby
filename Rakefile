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
    t.exclude_pattern = "spec/integration_spec.rb,spec/integration/**/*"
  end

  desc "Run integration specs"
  RSpec::Core::RakeTask.new(:integration) do |t|
    t.pattern = "spec/integration_spec.rb"
  end
end

RSpec::Core::RakeTask.new(:spec)
task :default => :spec
