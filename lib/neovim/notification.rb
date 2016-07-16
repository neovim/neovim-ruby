module Neovim
  # An asynchronous message from +nvim+.
  #
  # @api private
  class Notification
    attr_reader :method_name, :arguments

    def initialize(method_name, args)
      @method_name = method_name.to_s
      @arguments = args
    end

    def sync?
      false
    end
  end
end
