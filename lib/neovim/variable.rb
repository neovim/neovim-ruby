module Neovim
  class Variable
    class Error < RuntimeError; end

    module Scope
      class Error < RuntimeError; end

      class Global
        def self.regex
          /^(g:|[^:]+$)/
        end

        def self.getter_func_id
          31
        end

        def self.setter_func_id
          32
        end
      end

      class Vim
        def self.regex
          /^v:/
        end

        def self.getter_func_id
          33
        end

        def self.setter_func_id
          raise Error.new("Can't set builtin variables")
        end
      end
    end

    attr_reader :name, :value

    def initialize(var_name, client)
      case var_name
      when Scope::Vim.regex
        @scope = Scope::Vim
      when Scope::Global.regex
        @scope = Scope::Global
      else
        raise Error.new("Can't determine variable scope from name #{var_name}")
      end

      @client = client
      @name = var_name.sub(/^\w:/, '')
      @value = fetch_value
    end

    def value=(val)
      return val if @value == val

      @client.rpc_response(@scope.setter_func_id, @name, val)
      @value = val
    end

    private

    def fetch_value
      begin
        @client.rpc_response(@scope.getter_func_id, @name)
      rescue RPC::Error
        nil
      end
    end
  end
end
