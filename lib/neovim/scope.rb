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
      def getter_method_name
        :vim_get_var
      end

      def setter_method_name
        :vim_set_var
      end
    end

    class Buffer < Base
      def getter_method_name
        :buffer_get_var
      end

      def setter_method_name
        :buffer_set_var
      end
    end

    class Builtin < Base
      def getter_method_name
        :vim_get_vvar
      end

      def setter_method_name
        raise Error.new("Can't set builtin variables")
      end
    end
  end
end
