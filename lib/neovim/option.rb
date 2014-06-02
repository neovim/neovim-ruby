module Neovim
  class Option
    attr_reader :name, :value, :scope

    def initialize(name, scope, client)
      @name = name
      @scope = scope
      @client = client
      @value = fetch_value
    end

    def value=(val)
      return val if @value == val
      args = @scope.rpc_args + [@name, val]

      @client.rpc_response(@scope.set_option_method, *args)
      @value = val
    end

    private

    def fetch_value
      args = @scope.rpc_args + [@name]
      @client.rpc_response(@scope.get_option_method, *args)
    end
  end
end
