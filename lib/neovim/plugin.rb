require "neovim/plugin/dsl"

module Neovim
  # @api private
  class Plugin
    attr_accessor :handlers, :setup_blocks
    attr_reader :source

    def self.from_config_block(source)
      new(source).tap do |instance|
        yield DSL.new(instance) if block_given?
      end
    end

    def initialize(source)
      @handlers = []
      @source = source
      @setup_blocks = []
    end

    def specs
      @handlers.inject([]) do |acc, handler|
        handler.qualified? ? acc + [handler.to_spec] : acc
      end
    end

    def setup(client)
      @setup_blocks.each { |bl| bl.call(client) }
    end
  end
end
