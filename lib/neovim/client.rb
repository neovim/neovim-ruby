require "neovim/current"

module Neovim
  class Client
    attr_reader :session

    def initialize(session)
      @session = session
    end

    def method_missing(method_name, *args)
      if methods.include?(method_name)
        @session.request("vim_#{method_name}", *args)
      else
        super
      end
    end

    def respond_to?(method_name)
      super || methods.include?(method_name.to_sym)
    end

    def methods
      super | @session.api_methods_for_prefix("vim_")
    end

    def current
      Current.new(@session)
    end

    def stop
      @session.stop
    end
  end
end
