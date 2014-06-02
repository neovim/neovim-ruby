require "bundler/gem_tasks"

desc "Pretty print the Neovim message pack API"
task :discover_api do
  require "neovim"
  require "msgpack"
  require "pp"

  stream = Neovim::Stream.new("/tmp/neovim.sock", nil)
  response = Neovim::RPC.new([0, 0, 0, []], stream).response
  pp MessagePack.unpack(response[3][1])
end

desc "Start a Neovim instance to run the test suite against"
task :nvim do
  env = {"NEOVIM_LISTEN_ADDRESS" => "/tmp/neovim.sock"}
  neovim_pid = spawn(env, "nvim -u NONE")
  _, status = Process.waitpid2(neovim_pid)
  exit(status)
end
