module Neovim
  module Scope
    class Error < RuntimeError; end

    class Base
      attr_reader :rpc_args

      def initialize(*rpc_args)
        @rpc_args = rpc_args
      end
    end

    class Global < Base
      def get_variable_method
        :vim_get_var
      end

      def set_variable_method
        :vim_set_var
      end

      def get_option_method
        :vim_get_option
      end

      def set_option_method
        :vim_set_option
      end
    end

    class Buffer < Base
      def get_variable_method
        :buffer_get_var
      end

      def set_variable_method
        :buffer_set_var
      end

      def get_option_method
        :buffer_get_option
      end

      def set_option_method
        :buffer_set_option
      end
    end

    class Builtin < Base
      def get_variable_method
        :vim_get_vvar
      end

      def set_variable_method
        raise Error.new("Can't set builtin variables")
      end

      def get_option_method
        raise Error.new("Options can't be builtin scoped")
      end

      def set_option_method
        raise Error.new("Options can't be builtin scoped")
      end
    end
  end
end
