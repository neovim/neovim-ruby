module Neovim
  class Object
    attr_reader :index

    def initialize(index, session)
      @index = index
      @session = session
      @api = session.api
    end

    def respond_to?(method_name)
      super || rpc_methods.include?(method_name.to_sym)
    end

    def method_missing(method_name, *args)
      if rpc_methods.include?(method_name)
        @session.request(qualify(method_name), @index, *args)
      else
        super
      end
    end

    def to_msgpack(packer)
      packer.pack(@index)
    end

    def methods
      super | rpc_methods
    end

    private

    def rpc_methods
      @api.functions_with_prefix(function_prefix)
    end

    def function_prefix
      "#{self.class.to_s.split("::").last.downcase}_"
    end

    def qualify(method_name)
      :"#{function_prefix}#{method_name}"
    end
  end
end
