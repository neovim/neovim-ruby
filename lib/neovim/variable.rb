module Neovim
  class Variable
    class Error < RuntimeError; end

    module Scope
      class Error < RuntimeError; end

      class Global
        def self.regex
          /^(g:|[^:]+$)/
        end

        def self.getter_method_name
          :vim_get_var
        end

        def self.setter_method_name
          :vim_set_var
        end
      end

      class Vim
        def self.regex
          /^v:/
        end

        def self.getter_method_name
          :vim_get_vvar
        end

        def self.setter_method_name
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

      @client.rpc_response(@scope.setter_method_name, @name, val)
      @value = val
    end

    private

    def fetch_value
      begin
        @client.rpc_response(@scope.getter_method_name, @name)
      rescue RPC::Error
        nil
      end
    end
  end
end
