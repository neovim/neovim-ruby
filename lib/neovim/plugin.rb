require "neovim/plugin/dsl"

module Neovim
  # @api private
  class Plugin
    attr_accessor :handlers, :setup_blocks, :script_host
    attr_reader :source

    def self.from_config_block(source)
      new(source).tap do |instance|
        yield DSL.new(instance) if block_given?
      end
    end

    def initialize(source)
      @source = source
      @handlers = []
      @setup_blocks = []
      @script_host = false
    end

    def specs
      @handlers.inject([]) do |acc, handler|
        handler.qualified? ? acc + [handler.to_spec] : acc
      end
    end

    def setup(client)
      @setup_blocks.each { |bl| bl.call(client) }
    end

    def script_host?
      !!@script_host
    end
  end
end
