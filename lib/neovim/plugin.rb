require "neovim/plugin/dsl"

module Neovim
  class Plugin
    attr_accessor :handlers
    attr_reader :source

    def self.from_config_block(source, &block)
      new(source).tap do |instance|
        block.call(DSL.new(instance)) if block
      end
    end

    def initialize(source)
      @handlers = []
      @source = source
    end

    def specs
      @handlers.map(&:to_spec)
    end
  end
end
