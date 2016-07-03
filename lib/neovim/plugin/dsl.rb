require "neovim/plugin/handler"

module Neovim
  class Plugin
    # The DSL exposed in +Neovim.plugin+ blocks.
    class DSL < BasicObject
      def initialize(plugin)
        @plugin = plugin
      end

      # Register an +nvim+ command.
      #
      # @param name [String]
      # @param options [Hash]
      # @param &block [Proc, nil]
      #
      # @option options [Fixnum] :nargs
      # @option options [Fixnum] :count
      # @option options [String] :eval
      # @option options [Boolean] :sync (false)
      # @option options [Boolean] :bang
      # @option options [Boolean] :register
      # @option options [Boolean] :complete
      # @option options [String, Boolean] :range
      def command(name, options={}, &block)
        register_handler(:command, name, options, block)
      end

      # Register an +nvim+ function.
      #
      # @param name [String]
      # @param options [Hash]
      # @param &block [Proc, nil]
      #
      # @option options [String] :eval
      # @option options [Boolean] :sync (false)
      # @option options [String, Boolean] :range
      def function(name, options={}, &block)
        register_handler(:function, name, options, block)
      end

      # Register an +nvim+ autocmd.
      #
      # @param event [String]
      # @param options [Hash]
      # @param &block [Proc, nil]
      #
      # @option options [String] :pattern
      # @option options [String] :eval
      # @option options [Boolean] :sync (false)
      def autocmd(event, options={}, &block)
        register_handler(:autocmd, event, options, block)
      end

      # Register a top-level remote procedure call (RPC).
      #
      # This can be used to directly expose an RPC call without a namespace.
      # This is used primarily for exposing legacy ruby provider calls.
      #
      # @option options [Boolean] :sync (false)
      def rpc(name, options={}, &block)
        sync = options.delete(:sync)

        @plugin.handlers.push(
          Handler.unqualified(name, sync, options, block)
        )
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
