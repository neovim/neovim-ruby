require "neovim/plugin/handler"

module Neovim
  class Plugin
    # The DSL exposed in +Neovim.plugin+ blocks.
    #
    # @api public
    class DSL < BasicObject
      def initialize(plugin)
        @plugin = plugin
      end

      # Register an +nvim+ command. See +:h command+.
      #
      # @param name [String] The name of the command.
      # @param options [Hash] Command options.
      # @param &block [Proc, nil] The body of the command.
      #
      # @option options [Fixnum] :nargs The number of arguments to accept. See
      #   +:h command-nargs+.
      # @option options [String, Boolean] :range The range argument.
      #   See +:h command-range+.
      # @option options [Fixnum] :count The default count argument.
      #   See +:h command-count+.
      # @option options [Boolean] :bang Whether the command can take a +!+
      #   modifier. See +:h command-bang+.
      # @option options [Boolean] :register Whether the command can accept a
      #   register name. See +:h command-register+.
      # @option options [Boolean] :complete Set the completion attributes of
      #   the command. See +:h command-completion+.
      # @option options [String] :eval An +nvim+ expression. Gets evaluated and
      #   passed as an argument to the block.
      # @option options [Boolean] :sync (false) Whether +nvim+ should receive
      #   the return value of the block.
      def command(name, options={}, &block)
        register_handler(:command, name, options, block)
      end

      # Register an +nvim+ function. See +:h function+.
      #
      # @param name [String] The name of the function.
      # @param options [Hash] Function options.
      # @param &block [Proc, nil] The body of the function.
      #
      # @option options [String, Boolean] :range The range argument.
      #   See +:h command-range+.
      # @option options [String] :eval An +nvim+ expression. Gets evaluated and
      #   passed as an argument to the block.
      # @option options [Boolean] :sync (false) Whether +nvim+ should receive
      #   the return value of the block.
      def function(name, options={}, &block)
        register_handler(:function, name, options, block)
      end

      # Register an +nvim+ autocmd. See +:h autocmd+.
      #
      # @param event [String] The event type. See +:h autocmd-events+
      # @param options [Hash] Autocmd options.
      # @param &block [Proc, nil] The body of the autocmd.
      #
      # @option options [String] :pattern The buffer name pattern.
      #   See +:h autocmd-patterns+.
      # @option options [String] :eval An +nvim+ expression. Gets evaluated and
      #   passed as an argument to the block.
      def autocmd(event, options={}, &block)
        register_handler(:autocmd, event, options, block)
      end

      private

      # Directly define a synchronous RPC call without a namespace. This is
      # used for exposing legacy ruby provider calls, and not meant to be used
      # publicly in plugin definitions.
      def rpc(name, &block)
        @plugin.handlers.push(Handler.unqualified(name, block))
      end

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
