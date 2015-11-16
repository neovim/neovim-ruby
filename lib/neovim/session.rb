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
      fiber = Fiber.new do
        @async_session.request(method, *args) do |err, res|
          Fiber.yield(err, res)
        end.run
      end

      error, response = fiber.resume
      error ? raise(ArgumentError, error) : response
    end

    def api_methods_for_prefix(prefix)
      @api_info.functions.inject([]) do |acc, function|
        if function["name"] =~ /\A#{prefix}/
          acc + [function["name"].sub(/\A#{prefix}/, "").to_sym]
        else
          acc
        end
      end
    end
  end
end
