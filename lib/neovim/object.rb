module Neovim
  class Object
    attr_reader :index

    def initialize(index, session)
      @index = index
      @session = session
    end

    def respond_to?(method_name)
      super || methods.include?(method_name.to_sym)
    end

    def method_missing(method_name, *args)
      if methods.include?(method_name)
        @session.request(qualify(method_name), @index, *args)
      else
        super
      end
    end

    def to_msgpack(packer)
      packer.pack(@index)
    end

    def methods
      super | @session.api_methods_for_prefix(function_prefix)
    end

    private

    def function_prefix
      "#{self.class.to_s.split("::").last.downcase}_"
    end

    def qualify(method_name)
      :"#{function_prefix}#{method_name}"
    end
  end
end
