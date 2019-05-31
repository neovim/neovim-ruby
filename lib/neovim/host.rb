require "neovim"
require "neovim/client"
require "neovim/client_info"
require "neovim/event_loop"
require "neovim/host/loader"

module Neovim
  # @api private
  class Host
    include Logging

    attr_reader :plugins

    def self.run(rplugin_paths, event_loop=EventLoop.stdio)
      new(event_loop).tap do |host|
        Loader.new(host).load(rplugin_paths)
      end.run
    end

    def initialize(event_loop)
      @event_loop = event_loop
      @session = Session.new(event_loop)
      @handlers = {"poll" => poll_handler, "specs" => specs_handler}
      @plugins = []
      @specs = {}
    end

    def run
      @session.run { |msg| handle(msg) }
    end

    def handle(message)
      log(:debug) { message.to_h }

      @handlers
        .fetch(message.method_name, default_handler)
        .call(@client, message)
    rescue Exception => e
      log_exception(:error, e, __method__)

      if message.sync?
        @session.respond(message.id, nil, e.message)
      else
        @client.err_writeln("Exception handling #{message.method_name}: (#{e.class}) #{e.message}")
      end

      raise unless e.is_a?(StandardError)
    end

    private

    def poll_handler
      @poll_handler ||= lambda do |_, req|
        initialize_client(req.id)
        initialize_plugins

        @session.respond(req.id, "ok")
      end
    end

    def specs_handler
      @specs_handler ||= lambda do |_, req|
        source = req.arguments.fetch(0)

        if @specs.key?(source)
          @session.respond(req.id, @specs.fetch(source))
        else
          @session.respond(req.id, nil, "Unknown plugin #{source}")
        end
      end
    end

    def default_handler
      @default_handler ||= lambda do |_, message|
        next unless message.sync?
        @session.respond(message.id, nil, "Unknown request #{message.method_name}")
      end
    end

    def initialize_client(request_id)
      @session.request_id = request_id
      @session.notify(:nvim_set_client_info, *ClientInfo.for_host(self).to_args)

      @client = Client.from_event_loop(@event_loop, @session)
    end

    def initialize_plugins
      @plugins.each do |plugin|
        plugin.handlers.each do |handler|
          @handlers[handler.qualified_name] = wrap_plugin_handler(handler)
        end

        plugin.setup(@client)
        @specs[plugin.source] = plugin.specs
      end
    end

    def wrap_plugin_handler(handler)
      lambda do |client, message|
        args = message.arguments.flatten(1)
        result = handler.call(client, *args)

        @session.respond(message.id, result) if message.sync?
      end
    end
  end
end
