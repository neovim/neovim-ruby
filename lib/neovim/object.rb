module Neovim
  class Object
    attr_reader :index

    def initialize(index, client)
      @index  = index
      @client = client
      @handle = [index].pack("c*")
    end

    def to_msgpack
      @to_msgpack ||= begin
        type_code = @client.type_code(self.class)
        MessagePack::Extended.create(type_code, @handle)
      end
    end
  end
end
