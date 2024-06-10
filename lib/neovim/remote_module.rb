require "neovim/client"
require "neovim/event_loop"
require "neovim/logging"
require "neovim/remote_module/dsl"
require "neovim/session"

module Neovim
  class RemoteModule
    include Logging

    def self.from_config_block(&block)
      new(DSL::new(&block).handlers)
    end

    def initialize(handlers)
      @handlers = handlers
    end

    def start
      event_loop = EventLoop.stdio
      session = Session.new(event_loop)
      client = nil

      session.run do |message|
        case message
        when Message::Request
          begin
            client ||= Client.from_event_loop(event_loop, session)
            args = message.arguments.flatten(1)

            @handlers[message.method_name].call(client, *args).tap do |rv|
              session.respond(message.id, rv, nil) if message.sync?
            end
          rescue => e
            log_exception(:error, e, __method__)
            session.respond(message.id, nil, e.message) if message.sync?
          end
        end
      end
    end
  end
end
