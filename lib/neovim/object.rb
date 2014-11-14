module Neovim
  class Object
    attr_reader :index

    def initialize(index, client)
      @index  = index
      @client = client
      @handle = [index].pack("c*")
    end

    def msgpack_data
      @msgpack_data ||= begin
        type_code = @client.type_code(self.class)
        MessagePack::Extended.create(type_code, @handle)
      end
    end
  end
end
