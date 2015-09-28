require "neovim/current"
require "neovim/metadata"

module Neovim
  class Client
    def self.from_session(session)
      raw_metadata = session.request(:vim_get_api_info)
      session.metadata = Metadata.new(raw_metadata)
      new(session)
    end

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
      super || @session.metadata.defined?("vim_#{method_name}")
    end

    def current
      Current.new(@session)
    end
  end
end
