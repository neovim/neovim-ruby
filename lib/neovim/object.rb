module Neovim
  class Object
    attr_reader :index

    def initialize(index, session)
      @index = index
      @session = session
    end

    def respond_to?(method_name)
      super || @session.defined?(qualify(method_name))
    end

    def method_missing(method_name, *args)
      full_method = qualify(method_name)
      super unless @session.defined?(full_method)

      @session.request(full_method, @index, *args)
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

  Buffer  = Class.new(Object)
  Tabpage = Class.new(Object)
  Window  = Class.new(Object)
end
