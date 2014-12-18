module Neovim
  class Object
    attr_reader :index

    def initialize(index, client)
      @index  = index
      @client = client
      @handle = [index].pack("c*")
    end

    def method_missing(method_name, *args)
      funcdef = find_function(method_name)
      super unless funcdef

      response = @client.rpc_send(funcdef.fetch("name"), self, *args)
      funcdef.fetch("return_type") == "void" ?  self : response
    end

    def respond_to?(method_name)
      super || !!find_function(method_name)
    end

    def msgpack_data
      @msgpack_data ||= begin
        type_code = @client.type_code_for(self.class)
        MessagePack::Extended.create(type_code, @handle)
      end
    end

    private

    def find_function(function)
      prefix = self.class.to_s.split("::").last.downcase
      @client.find_function("#{prefix}_#{function}")
    end
  end

  Buffer  = Class.new(Object)
  Tabpage = Class.new(Object)
  Window  = Class.new(Object)
end
