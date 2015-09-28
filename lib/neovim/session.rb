module Neovim
  class Session
    attr_reader :metadata

    def initialize(async_session)
      @async_session = async_session
    end

    def metadata=(metadata)
      @metadata = metadata
      @async_session.register_session(self)
    end

    def request(method, *args)
      err = res = nil

      @async_session.request(method, *args) do |error, response|
        err, res = error, response
        stop
      end.run

      err ? raise(ArgumentError, err) : res
    end

    def stop
      @async_session.stop
    end
  end
end
