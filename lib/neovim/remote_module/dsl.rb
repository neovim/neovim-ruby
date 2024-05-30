module Neovim
  class RemoteModule
    # The DSL exposed in +Neovim.start_remote+ blocks.
    #
    # @api public
    class DSL < BasicObject
      attr_reader :handlers

      def initialize(&block)
        @handlers = ::Hash.new do |h, name|
          h[name] = ::Proc.new do |_, *|
            raise NotImplementedError, "undefined handler #{name.inspect}"
          end
        end

        block&.call(self)
      end

      # Define an RPC handler for use in remote modules.
      #
      # @param name [String] The handler name.
      # @param block [Proc] The body of the handler.
      def register_handler(name, &block)
        @handlers[name.to_s] = ::Proc.new do |client, *args|
          block.call(client, *args)
        end
      end
    end
  end
end
