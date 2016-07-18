require "neovim/logging"
require "neovim/host/loader"

module Neovim
  # @api private
  class Host
    include Logging

    attr_reader :handlers, :specs

    # Initialize and populate a +Host+ from a list of plugin paths.
    #
    # @param rplugin_paths [Array<String>]
    # @return [Host]
    # @see Loader#load
    def self.load_from_files(rplugin_paths, options={})
      session = options.fetch(:session) { Session.stdio }
      client = options.fetch(:client) { Client.new(session) }

      new(session, client).tap do |host|
        Loader.new(host).load(rplugin_paths)
      end
    end

    def initialize(session, client)
      @session = session
      @client = client
      @handlers = {"poll" => poll_handler, "specs" => specs_handler}
      @specs = {}
    end

    # Register a +Plugin+ to receive +Host+ messages.
    #
    # @param plugin [Plugin]
    def register(plugin)
      plugin.handlers.each do |handler|
        @handlers[handler.qualified_name] = wrap_plugin_handler(handler)
      end

      @specs[plugin.source] = plugin.specs
    end

    # Run the event loop, passing received messages to the appropriate handler.
    #
    # @return [void]
    def run
      @session.run { |msg| handle(msg) }
    rescue => e
      fatal("got unexpected error #{e.inspect}")
      debug(e.backtrace.join("\n"))
    end

    # Handle messages received from the host. Sends a +Neovim::Client+ along
    # with the message to be used in plugin callbacks.
    #
    # @param message [Neovim::Request, Neovim::Notification]
    # @param client [Neovim::Client]
    def handle(message)
      debug("received #{message.inspect}")

      @handlers.
        fetch(message.method_name, default_handler).
        call(@client, message)
    rescue => e
      fatal("got unexpected error #{e.inspect}")
      debug(e.backtrace.join("\n"))
    end

    private

    def poll_handler
      @poll_handler ||= Proc.new do |_, req|
        debug("received 'poll' request #{req.inspect}")
        req.respond("ok")
      end
    end

    def specs_handler
      @specs_handler ||= Proc.new do |_, req|
        debug("received 'specs' request #{req.inspect}")
        source = req.arguments.fetch(0)

        if @specs.key?(source)
          req.respond(@specs.fetch(source))
        else
          req.error("Unknown plugin #{source}")
        end
      end
    end

    def default_handler
      @default_handler ||= Proc.new do |_, message|
        if message.sync?
          message.error("Unknown request #{message.method_name}")
        end
      end
    end

    def wrap_plugin_handler(handler)
      Proc.new do |client, message|
        begin
          debug("received #{message.inspect}")
          args = message.arguments.flatten(1)
          result = handler.call(client, *args)
          message.respond(result) if message.sync?
        rescue => e
          warn("got unexpected error #{e.inspect}")
          message.error(e.message) if message.sync?
        end
      end
    end
  end
end
