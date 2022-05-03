require "neovim/client"
require "neovim/client_info"
require "neovim/session"
require "neovim/event_loop"
require "neovim/executable"
require "neovim/logging"
require "neovim/version"

# The main entrypoint to the +Neovim+ gem. It allows you to connect to a
# running +nvim+ instance programmatically or define a remote plugin to be
# autoloaded by +nvim+.
#
# You can connect to a running +nvim+ process using the appropriate +attach_+
# method. This is currently supported for both UNIX domain sockets and TCP. You
# can also spawn and connect to an +nvim+ subprocess using
# +Neovim.attach_child+.
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
#     plug.command(:SetLine, nargs: 1) do |nvim, str|
#       nvim.current.line = str
#     end
#
#     # Define a function called "Sum" which adds two numbers. This function is
#     # executed synchronously, so the result of the block will be returned to
#     # nvim.
#     plug.function(:Sum, nargs: 2, sync: true) do |nvim, x, y|
#       x + y
#     end
#
#     # Define an autocmd for the BufEnter event on Ruby files.
#     plug.autocmd(:BufEnter, pattern: "*.rb") do |nvim|
#       nvim.command("echom 'Ruby file, eh?'")
#     end
#   end
#
# @see Client
# @see Plugin::DSL
module Neovim
  # Connect to a running +nvim+ instance over TCP.
  #
  # @param host [String] The hostname or IP address
  # @param port [Integer] The port
  # @return [Client]
  # @see EventLoop.tcp
  def self.attach_tcp(host, port)
    attach(EventLoop.tcp(host, port))
  end

  # Connect to a running +nvim+ instance over a UNIX domain socket.
  #
  # @param socket_path [String] The socket path
  # @return [Client]
  # @see EventLoop.unix
  def self.attach_unix(socket_path)
    attach(EventLoop.unix(socket_path))
  end

  # Spawn and connect to a child +nvim+ process.
  #
  # @param argv [Array] The arguments to pass to the spawned process
  # @return [Client]
  # @see EventLoop.child
  def self.attach_child(argv=[executable.path])
    attach(EventLoop.child(argv))
  end

  # Placeholder method for exposing the remote plugin DSL. This gets
  # temporarily overwritten in +Host::Loader#load+.
  #
  # @see Host::Loader#load
  # @see Plugin::DSL
  def self.plugin
    raise "Can't call Neovim.plugin outside of a plugin host."
  end

  # Return a +Neovim::Executable+ representing the active +nvim+ executable.
  #
  # @return [Executable]
  # @see Executable
  def self.executable
    @executable ||= Executable.from_env
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

  # @api private
  def self.attach(event_loop)
    Client.from_event_loop(event_loop).tap do |client|
      client.session.notify(:nvim_set_client_info, *ClientInfo.for_client.to_args)
    end
  end
  private_class_method :attach
end
