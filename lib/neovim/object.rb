module Neovim
  class Object
    attr_reader :index

    def initialize(index, rpc)
      @index  = index
      @rpc = rpc
    end

    def method_missing(method_name, *args)
      prefix = self.class.to_s.split("::").last.downcase
      full_method = :"#{prefix}_#{method_name}"
      super unless @rpc.defined?(full_method)

      @rpc.send(full_method, @index, *args)
    end
  end

  Buffer  = Class.new(Object)
  Tabpage = Class.new(Object)
  Window  = Class.new(Object)
end
