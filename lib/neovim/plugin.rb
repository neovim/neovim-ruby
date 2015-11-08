module Neovim
  class Plugin
    def self.from_config_block(&block)
      new.tap do |instance|
        block.call(DSL.new(instance)) if block
      end
    end

    attr_accessor :specs

    def initialize
      @specs = []
    end

    class DSL < BasicObject
      def initialize(plugin)
        @plugin = plugin
      end

      def command(name, _options={}, &block)
        options = _options.dup
        options[:range] = "" if options[:range] == true
        options[:range] = ::Kernel.String(options[:range])

        @plugin.specs.push(
          :type => :command,
          :name => name.to_sym,
          :sync => !!options.delete(:sync),
          :opts => options,
          :proc => block || ::Proc.new {}
        )
      end

      def function(name, _options, &block)
        options = _options.dup
        options[:range] = "" if options[:range] == true
        options[:range] = ::Kernel.String(options[:range])

        @plugin.specs.push(
          :type => :function,
          :name => name.to_sym,
          :sync => !!options.delete(:sync),
          :opts => options,
          :proc => block || ::Proc.new {}
        )
      end

      def autocmd(name, _options={}, &block)
        options = _options.dup

        @plugin.specs.push(
          :type => :autocmd,
          :name => name.to_sym,
          :sync => !!options.delete(:sync),
          :opts => options,
          :proc => block || ::Proc.new {}
        )
      end
    end
  end
end
