require "neovim/client"
require "neovim/host"
require "neovim/session"
require "neovim/plugin"

# The main entrypoint to the +Neovim+ gem. It allows you to connect to a
# running +nvim+ instance programmatically or define a remote plugin to be
# autoloaded by +nvim+.
#
# You can connect to a running +nvim+ instance by setting or inspecting the
# +NVIM_LISTEN_ADDRESS+ environment variable and connecting via the appropriate
# +attach_+ method. This is currently supported for both UNIX domain sockets
# and TCP. You can also spawn and connect to an +nvim+ subprocess via
# +Neovim.attach_child(argv)+.
#
# You can define a remote plugin using the +Neovim.plugin+ DSL, which allows
# you to register commands, functions, and autocmds. Plugins are autoloaded by
# +nvim+ from the +rplugin/ruby+ directory in your +nvim+ runtime path.
#
# @example Connect over a TCP socket
#   Neovim.attach_tcp("0.0.0.0", 3333) # => Neovim::Client
#
# @example Connect over a UNIX domain socket
#   Neovim.attach_unix("/tmp/nvim.sock") # => Neovim::Client
#
# @example Spawn and connect to a child +nvim+ process
#   Neovim.attach_child(["nvim", "--embed"]) # => Neovim::Client
#
# @example Define a Ruby plugin
#   # ~/.config/nvim/rplugin/ruby/plugin.rb
#
#   Neovim.plugin do |plug|
#     # Define a command called "SetLine" which sets the contents of the
#     # current line. This command is executed asynchronously, so the return
#     # value is ignored.
#     plug.command(:SetLine, :nargs => 1) do |nvim, str|
#       nvim.current.line = str
#     end
#
#     # Define a function called "Sum" which adds two numbers. This function is
#     # executed synchronously, so the result of the block will be returned to
#     # nvim.
#     plug.function(:Sum, :nargs => 2, :sync => true) do |nvim, x, y|
#       x + y
#     end
#
#     # Define an autocmd for the BufEnter event on Ruby files.
#     plug.autocmd(:BufEnter, :pattern => "*.rb") do |nvim|
#       nvim.command("echom 'Ruby file, eh?'")
#     end
#   end
#
# @see Client
# @see Plugin::DSL
module Neovim
  class << self
    # @api private
    # @return [Manifest, nil]
    attr_accessor :__configured_plugin_manifest

    # @api private
    # @return [String, nil]
    attr_accessor :__configured_plugin_path
  end

  # Connect to a running +nvim+ instance over TCP.
  #
  # @param host [String] The hostname or IP address
  # @param port [Fixnum] The port
  # @return [Client]
  # @see Session.tcp
  def self.attach_tcp(host, port)
    Client.new Session.tcp(host, port)
  end

  # Connect to a running +nvim+ instance over a UNIX domain socket.
  #
  # @param socket_path [String] The socket path
  # @return [Client]
  # @see Session.unix
  def self.attach_unix(socket_path)
    Client.new Session.unix(socket_path)
  end

  # Spawn and connect to a child +nvim+ process.
  #
  # @param argv [Array] The arguments to pass to the spawned process
  # @return [Client]
  # @see Session.child
  def self.attach_child(argv=[])
    Client.new Session.child(argv)
  end

  # Define an +nvim+ remote plugin using the plugin DSL.
  #
  # @yield [Plugin::DSL]
  # @return [Plugin]
  # @see Plugin::DSL
  def self.plugin(&block)
    Plugin.from_config_block(__configured_plugin_path, &block).tap do |plugin|
      if __configured_plugin_manifest.respond_to?(:register)
        __configured_plugin_manifest.register(plugin)
      end
    end
  end

  # Start a plugin host. This is called by the +nvim-ruby-host+ executable,
  # which is spawned by +nvim+ to discover and run Ruby plugins, and acts as
  # the bridge between +nvim+ and the plugin.
  #
  # @param rplugin_paths [Array<String>] The paths to remote plugin files
  # @return [void]
  # @see Host
  def self.start_host(rplugin_paths)
    Host.load_from_files(rplugin_paths).run
  end

  # Set the Neovim global logger.
  #
  # @param logger [Logger] The target logger
  # @return [Logger]
  # @see Logging
  def self.logger=(logger)
    Logging.logger = logger
  end

  # The Neovim global logger.
  #
  # @return [Logger]
  # @see Logging
  def self.logger
    Logging.logger
  end
end
