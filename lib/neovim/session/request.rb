module Neovim
  class Session
    # A synchronous message to or from +nvim+.
    #
    # @api private
    class Request
      attr_reader :id, :method_name, :arguments

      def initialize(id, method_name, args)
        @id = id
        @method_name = method_name.to_s
        @arguments = args
      end

      def sync?
        true
      end
    end
  end
end
