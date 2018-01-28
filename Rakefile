require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"

RuboCop::RakeTask.new(:style)

namespace :vim_flavor do
  desc "Install VimFlavor dependencies"
  task :install do
    sh "bundle exec vim-flavor install --vimfiles-path=spec/acceptance"
  end
end

namespace :spec do
  desc "Run functional specs"
  RSpec::Core::RakeTask.new(:functional)

  desc "Run acceptance specs"
  task acceptance: "vim_flavor:install" do
    run_script(:run_acceptance, "--reporter", "dot", "spec/acceptance")
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

task :default do
  sh "bash", "-c", "echo hi"
end

def run_script(script_name, *args)
  sh(
    RbConfig.ruby,
    File.expand_path("../script/#{script_name}.rb", __FILE__),
    *args
  )
end
