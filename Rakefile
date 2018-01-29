require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"

RuboCop::RakeTask.new(:style)

namespace :spec do
  desc "Run functional specs"
  RSpec::Core::RakeTask.new(:functional)

  desc "Run acceptance specs"
  task acceptance: "acceptance:deps" do
    run_script(:run_acceptance, "--reporter", "dot", "spec/acceptance")
  end

  namespace :acceptance do
    desc "Install acceptance spec dependencies"
    task :deps do
      sh "bundle exec vim-flavor install --vimfiles-path=spec/acceptance"
    end
  end
end

namespace :docs do
  desc "Generate Neovim remote API docs"
  task :generate do
    run_script(:generate_docs)
  end

  desc "Validate generated documentation is up-to-date"
  task :validate do
    run_script(:validate_docs)
  end
end

task default: [:style, "spec:functional", "spec:acceptance", "docs:validate"]

def run_script(script_name, *args)
  ruby File.expand_path("../script/#{script_name}.rb", __FILE__), *args
end
