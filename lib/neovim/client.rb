module Neovim
  class Client
    def self.from_session(session)
      channel_id, metadata = session.request(:vim_get_api_info)
      new(session, channel_id, metadata)
    end

    def initialize(session, channel_id, metadata)
      @session = session
      @channel_id = channel_id
      @metadata = metadata
    end

    def method_missing(method_name, *args)
      if respond_to?(method_name)
        full_name = "vim_#{method_name}"
        err, res = @session.request(full_name, *args)

        err ? raise(ArgumentError, err) : res
      else
        super
      end
    end

    def respond_to?(method_name)
      super || @metadata.fetch(1).fetch("functions").any? do |func|
        func["name"] == "vim_#{method_name}"
      end
    end

    #def current
    #  Current.new(@session)
    #end
  end
end
