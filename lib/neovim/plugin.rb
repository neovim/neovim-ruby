module Neovim
  class Plugin
    def self.from_config_block(source, &block)
      new(source).tap do |instance|
        block.call(DSL.new(instance)) if block
      end
    end

    attr_accessor :handlers
    attr_reader :source

    def initialize(source)
      @handlers = []
      @source = source
    end

    def specs
      @handlers.map(&:to_spec)
    end

    class Handler
      attr_reader :source, :name, :block

      def initialize(source, type, name, sync, options, block)
        @source = source
        @type = type.to_sym
        @name = name.to_sym
        @sync = !!sync
        @options = options
        @block = block || ::Proc.new {}
      end

      def qualified_name
        if @type == :autocmd
          pattern = options.fetch(:pattern, "*")
          :"#{@source}:#{@type}:#{@name}:#{pattern}"
        else
          :"#{@source}:#{@type}:#{@name}"
        end
      end

      def sync?
        @sync
      end

      def to_spec
        {
          :type => @type,
          :name => @name,
          :sync => @sync,
          :opts => @options,
        }
      end

      def call(*args)
        @block.call(*args)
      end
    end

    class DSL < BasicObject
      def initialize(plugin)
        @plugin = plugin
      end

      def command(name, options={}, &block)
        register_handler(:command, name, options, block)
      end

      def function(name, options={}, &block)
        register_handler(:function, name, options, block)
      end

      def autocmd(name, options={}, &block)
        register_handler(:autocmd, name, options, block)
      end

      private

      def register_handler(type, name, _options, block)
        if type == :autocmd
          options = _options.dup
        else
          options = standardize_range(_options.dup)
        end

        sync = options.delete(:sync)

        @plugin.handlers.push(
          Handler.new(@plugin.source, type, name, sync, options, block)
        )
      end

      def standardize_range(options)
        if options.key?(:range)
          options[:range] = "" if options[:range] == true
          options[:range] = ::Kernel.String(options[:range])
        end

        options
      end
    end
  end
end
