require "neovim/current"

module Neovim
  class Client
    attr_reader :session

    def initialize(session)
      @session = session
      @api = session.api
    end

    def method_missing(method_name, *args)
      if func = @api.function("vim_#{method_name}")
        func.call(session, *args)
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
      @api.functions_with_prefix("vim_").map do |func|
        func.name.sub(/\Avim_/, "").to_sym
      end
    end
  end
end
