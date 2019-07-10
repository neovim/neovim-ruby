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
      Bundler.with_clean_env do
        sh "bundle exec vim-flavor update --vimfiles-path=spec/acceptance/runtime"
      end
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

namespace :ci do
  desc "Run tests on CI"
  task test: [:style, :download_nvim, :default]

  desc "Generate docs on CI"
  task docs: [:download_nvim, :"ci:generate_and_push_docs"]

  task :generate_and_push_docs do
    run_script("ci/generate_and_push_docs")
  end

  task :download_nvim do
    run_script("ci/download_nvim")
  end
end

task default: [
  :style,
  :"spec:functional",
  :"spec:acceptance"
]

def run_script(script_name, *args)
  sh File.expand_path("script/#{script_name}", __dir__), *args
end
