module Neovim
  class Session
    def initialize(async_session)
      @async_session = async_session
      @pending_requests = []
      @pending_notifications = []
    end

    def request(method, *args)
      result = nil

      @async_session.request(method, *args) do |error, response|
        result = [error, response]
        stop
      end

      @async_session.run(
        method(:enqueue_request),
        method(:enqueue_notification)
      )

      result
    end

    def stop
      @async_session.stop
    end

    private

    def enqueue_request(method, args, response)
      @pending_requests.push([method, args, response])
    end

    def enqueue_notification(event, args)
      @pending_notifications.push([event, args])
    end
  end
end
