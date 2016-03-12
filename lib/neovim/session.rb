require "neovim/api_info"

module Neovim
  class Session
    def initialize(async_session)
      @async_session = async_session
    end

    def discover_api
      @api = APIInfo.new(request(:vim_get_api_info))
      self
    end

    def api
      @api ||= APIInfo.null
    end

    def request(method, *args)
      fiber = Fiber.new do
        @async_session.request(method, *args) do |err, res|
          Fiber.yield(err, res)
        end.run(nil, nil, self)
      end

      error, response = fiber.resume
      error ? raise(ArgumentError, error) : response
    end
  end
end
