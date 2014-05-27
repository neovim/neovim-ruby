require "bundler/gem_tasks"

desc "Show the Neovim message pack API in YAML format"
task :discover_api do
  require "neovim"
  require "yaml"

  stream = Neovim::Stream.new("/tmp/neovim.sock", nil)
  puts YAML.dump(Neovim.discover_api(stream))
end

namespace :remote do
  desc "Listen for signals to restart the remote process"
  task :listen do
    require File.expand_path("../spec/support/remote.rb", __FILE__)
    Remote.new("/tmp/neovim.sock").listen
  end
end
