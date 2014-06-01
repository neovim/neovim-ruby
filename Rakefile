require "bundler/gem_tasks"

desc "Show the Neovim message pack API in YAML format"
task :discover_api do
  require "neovim"
  require "yaml"

  stream = Neovim::Stream.new("/tmp/neovim.sock", nil)
  puts YAML.dump(Neovim.discover_api(stream))
end

desc "Start a Neovim instance to run the test suite against"
task :nvim do
  env = {"NEOVIM_LISTEN_ADDRESS" => "/tmp/neovim.sock"}
  neovim_pid = spawn(env, "nvim -u NONE")
  _, status = Process.waitpid2(neovim_pid)
  exit(status)
end
