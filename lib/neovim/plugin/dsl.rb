require "neovim/plugin/handler"

module Neovim
  class Plugin
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
