module Neovim
  class Variable
    attr_reader :name, :value

    def initialize(name, scope, client)
      @name = name
      @scope = scope
      @client = client
      @value = fetch_value
    end

    def value=(val)
      return val if @value == val
      args = @scope.rpc_args + [@name, val]

      @client.rpc_response(@scope.setter_method_name, *args)
      @value = val
    end

    private

    def fetch_value
      begin
        args = @scope.rpc_args + [@name]
        @client.rpc_response(@scope.getter_method_name, *args)
      rescue RPC::Error
        nil
      end
    end
  end
end
