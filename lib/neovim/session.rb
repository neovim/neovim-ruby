module Neovim
  class Session
    def initialize(async_session)
      @async_session = async_session
    end

    def request(method, *args)
      result = nil

      @async_session.request(method, *args) do |error, response|
        result = [error, response]
        stop
      end.run

      result
    end

    def stop
      @async_session.stop
    end
  end
end
