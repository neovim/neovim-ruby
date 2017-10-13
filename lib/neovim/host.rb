require "neovim"
require "neovim/client"
require "neovim/event_loop"
require "neovim/host/loader"

module Neovim
  # @api private
  class Host
    include Logging

    # Start a plugin host. This is called by the +nvim-ruby-host+ executable,
    # which is spawned by +nvim+ to discover and run Ruby plugins, and acts as
    # the bridge between +nvim+ and the plugin.
    def self.run(rplugin_paths, event_loop=EventLoop.stdio)
      client = Client.from_event_loop(event_loop)

      new(client).tap do |host|
        Loader.new(host).load(rplugin_paths)
      end.run
    end

    def initialize(client)
      @client = client
      @session = client.session
      @handlers = {"poll" => poll_handler, "specs" => specs_handler}
      @specs = {}
    end

    # Register a +Plugin+ to receive +Host+ messages.
    def register(plugin)
      plugin.handlers.each do |handler|
        @handlers[handler.qualified_name] = wrap_plugin_handler(handler)
      end

      plugin.setup(@client)
      @specs[plugin.source] = plugin.specs
    end

    # Run the event loop, passing received messages to the appropriate handler.
    def run
      @session.run { |msg| handle(msg) }
    ensure
      @client.shutdown
      @session.shutdown
    end

    # Handle messages received from the host. Sends a +Neovim::Client+ along
    # with the message to be used in plugin callbacks.
    def handle(message)
      log_debug(__method__, :message => message.to_h)

      @handlers.
        fetch(message.method_name, default_handler).
        call(@client, message)
    rescue SignalException => ex
      log_error(__method__, ex)
    rescue => ex
      log_fatal(__method__, ex)
    end

    private

    def poll_handler
      @poll_handler ||= Proc.new do |_, req|
        @session.respond(req.id, "ok")
      end
    end

    def specs_handler
      @specs_handler ||= Proc.new do |_, req|
        source = req.arguments.fetch(0)

        if @specs.key?(source)
          @session.respond(req.id, @specs.fetch(source))
        else
          @session.respond(req.id, nil, "Unknown plugin #{source}")
        end
      end
    end

    def default_handler
      @default_handler ||= Proc.new do |_, message|
        next unless message.sync?
        @session.respond(message.id, nil, "Unknown request #{message.method_name}")
      end
    end

    def wrap_plugin_handler(handler)
      Proc.new do |client, message|
        begin
          args = message.arguments.flatten(1)
          result = handler.call(client, *args)

          @session.respond(message.id, result) if message.sync?
        rescue => e
          log_error(__method__, e)
          @session.respond(message.id, nil, e.message) if message.sync?
        end
      end
    end
  end
end
