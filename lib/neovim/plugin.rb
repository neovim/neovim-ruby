require "neovim/plugin/dsl"

module Neovim
  class Plugin
    attr_accessor :handlers
    attr_reader :source

    # Entrypoint to the +Neovim.plugin+ DSL.
    #
    # @param source [String] The path of the plugin file.
    # @yield [DSL] The receiver of DSL methods.
    def self.from_config_block(source)
      new(source).tap do |instance|
        yield DSL.new(instance) if block_given?
      end
    end

    def initialize(source)
      @handlers = []
      @source = source
    end

    # @return [Array] Handler specs used by +nvim+ to register plugins.
    def specs
      @handlers.map(&:to_spec)
    end
  end
end
