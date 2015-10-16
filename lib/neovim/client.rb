require "neovim/current"

module Neovim
  class Client
    def initialize(session)
      @session = session
    end

    def method_missing(method_name, *args)
      if respond_to?(method_name)
        @session.request("vim_#{method_name}", *args)
      else
        super
      end
    end

    def respond_to?(method_name)
      super || @session.defined?("vim_#{method_name}")
    end

    def methods
      super | @session.api_methods_for_prefix("vim_")
    end

    def current
      Current.new(@session)
    end
  end
end
