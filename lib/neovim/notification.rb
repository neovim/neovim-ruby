module Neovim
  class Notification
    attr_reader :method_name, :arguments

    def initialize(method_name, args)
      @method_name = method_name.to_sym
      @arguments = args
    end
  end
end
