require "bundler/gem_tasks"

desc "Show the Neovim message pack API in YAML format"
task :discover_api do
  require "neovim"
  require "yaml"

  socket_path = ENV["NEOVIM_LISTEN_ADDRESS"] || "/tmp/neovim.sock"

  stream = Neovim::Stream.new(socket_path, nil)
  puts YAML.dump(Neovim.discover_api(stream))
end
