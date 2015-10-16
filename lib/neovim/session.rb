require "neovim/api_info"

module Neovim
  class Session
    attr_reader :api_info

    def initialize(async_session)
      @async_session = async_session

      @api_info = APIInfo.new(request(:vim_get_api_info))
      @async_session.register_session(self)
    end

    def request(method, *args)
      err = res = nil

      @async_session.request(method, *args) do |error, response|
        err, res = error, response
        @async_session.stop
      end.run

      err ? raise(ArgumentError, err) : res
    end

    def defined?(method_name)
      @api_info.defined?(method_name)
    end
  end
end
