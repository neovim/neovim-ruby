module Neovim
  class Client
    def initialize(rpc)
      @rpc = rpc
    end

    def respond_to?(method_name)
      super || @rpc.defined?(:"vim_#{method_name}")
    end

    def method_missing(method_name, *args)
      full_method = :"vim_#{method_name}"
      super unless @rpc.defined?(full_method)
      @rpc.send(full_method, *args)
    end

    def current
      Current.new(@rpc)
    end
  end
end
