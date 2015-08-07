require "neovim/rpc"

module Neovim
  class Client
    def initialize(io)
      @rpc = RPC.new(io, self)
      @rpc.register_types(types)
    end

    def method_missing(method_name, *args)
      funcdef = find_function("vim_#{method_name}")
      super unless funcdef

      response = rpc_send(funcdef.fetch("name"), *args)
      funcdef.fetch("return_type") == "void" ?  self : response
    end

    def respond_to?(method_name)
      super || !!find_function("vim_#{method_name}")
    end

    def current
      Current.new(self)
    end

    def rpc_send(method_name, *args)
      @rpc.send(method_name, *args).response
    end

    def api_info
      @api_info ||= rpc_send(:vim_get_api_info)
    end

    def find_function(name)
      functions.find { |funcdef| funcdef.fetch("name") == name }
    end

    private

    def types
      @types ||= api_info.fetch(1).fetch("types")
    end

    def functions
      @functions ||= api_info.fetch(1).fetch("functions")
    end
  end
end
