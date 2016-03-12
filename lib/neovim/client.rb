require "neovim/current"

module Neovim
  class Client
    attr_reader :session

    def initialize(session)
      @session = session
      @api = session.api
    end

    def method_missing(method_name, *args)
      if rpc_methods.include?(method_name)
        @session.request("vim_#{method_name}", *args)
      else
        super
      end
    end

    def respond_to?(method_name)
      super || rpc_methods.include?(method_name.to_sym)
    end

    def methods
      super | rpc_methods
    end

    def current
      Current.new(@session)
    end

    private

    def rpc_methods
      @api.functions_with_prefix("vim_")
    end
  end
end
