module Neovim
  class Option
    attr_reader :name, :value

    def initialize(name, client)
      @name = name
      @client = client
      @value = fetch_value
    end

    def value=(val)
      @client.rpc_response(35, @name, val)
      @value = val
    end

    private

    def fetch_value
      begin
        @client.rpc_response(34, @name)
      rescue RPC::Error
        nil
      end
    end
  end
end
