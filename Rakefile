require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"

RuboCop::RakeTask.new(:linter)

namespace :spec do
  desc "Run functional specs"
  RSpec::Core::RakeTask.new(:functional)

  desc "Run acceptance specs"
  task acceptance: "acceptance:deps" do
    run_script("run_acceptance.rb", "--reporter", "dot", "spec/acceptance")
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
    run_script("generate_docs.rb")
  end

  desc "Validate generated documentation is up-to-date"
  task :validate do
    run_script("validate_docs.rb")
  end
end

namespace :ci do
  task :generate_and_push_docs do
    run_script("ci/generate_and_push_docs.sh")
  end

  task :download_nvim do
    run_script("ci/download_nvim.sh")
  end
end

desc "Run specs"
task spec: [:"spec:functional", :"spec:acceptance"]

task default: [:linter, :spec]

def run_script(relpath, *args)
  path = File.expand_path("script/#{relpath}", __dir__)
  cmd_handler = ->(ok, status) { ok || exit(status.exitstatus) }

  if File.extname(path) == ".rb"
    ruby(path, *args, &cmd_handler)
  else
    sh(path, *args, &cmd_handler)
  end
end
