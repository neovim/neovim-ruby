require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)
task :default => :spec

RSpec::Core::RakeTask.new("spec:ci") do |t|
  begin
    Rake::Task["neovim:install"].invoke
  rescue
    puts "Neovim install failed, retrying"
    Rake::Task["neovim:install"].reenable
    Rake::Task["neovim:install"].invoke
  end
end

namespace :neovim do
  vendor = File.expand_path("../vendor/neovim", __FILE__)

  desc "Install Neovim"
  task :install do
    sh "git submodule update --init && " +
       "cd #{vendor} && " +
       "make distclean && " +
       "make"
  end

  desc "Update Neovim installation"
  task :update do
    sh "git submodule update --init && " +
       "cd #{vendor} && " +
       "make distclean && " +
       "git pull origin master && " +
       "make"
  end

  desc "Dump Neovim API metadata"
  task :api_info do
    require "rubygems"
    require "bundler/setup"
    require "neovim"
    require "yaml"

    require File.expand_path("../spec/support.rb", __FILE__)
    include Support::Remote

    with_neovim_client do |client|
      api_info = client.rpc_send(:vim_get_api_info)
      function = ENV["function"]
      funcdefs = api_info.fetch(1).fetch("functions")

      if function
        regexp = Regexp.new(function)
        funcdefs.select! { |func| func.fetch("name") =~ regexp }
      end

      funcdefs.each do |funcdef|
        name = funcdef.fetch("name")
        return_type = funcdef.fetch("return_type")
        params = funcdef.fetch("parameters")
        param_str = params.map { |p| p.join(" ") }.join(", ")

        puts "#{name}(#{param_str}) # => #{return_type}"
      end
    end
  end
end
