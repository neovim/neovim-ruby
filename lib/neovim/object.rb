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
      if func = @api.function(qualify(method_name))
        func.call(@session, @index, *args)
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
      @api.functions_with_prefix(function_prefix).map do |func|
        func.name.sub(/\A#{function_prefix}/, "").to_sym
      end
    end

    def function_prefix
      "#{self.class.to_s.split("::").last.downcase}_"
    end

    def qualify(method_name)
      :"#{function_prefix}#{method_name}"
    end
  end
end
