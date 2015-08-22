module Neovim
  class Object
    attr_reader :index

    def initialize(index, rpc)
      @index = index
      @rpc = rpc
    end

    def respond_to?(method_name)
      super || @rpc.defined?(qualify(method_name))
    end

    def method_missing(method_name, *args)
      full_method = qualify(method_name)
      super unless @rpc.defined?(full_method)

      @rpc.send(full_method, @index, *args)
    end

    private

    def qualify(string)
      prefix = self.class.to_s.split("::").last.downcase
      :"#{prefix}_#{string}"
    end
  end

  Buffer  = Class.new(Object)
  Tabpage = Class.new(Object)
  Window  = Class.new(Object)
end
