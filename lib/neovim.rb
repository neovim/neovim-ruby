require "neovim/version"
require "neovim/stream"
require "neovim/rpc"

module Neovim
  Remote = Struct.new(:vim, :handle)

  def self.discover_api(stream)
    response = RPC.new([0, 0, 0, []], stream).response
    api = MessagePack.unpack(response[3])

    const_set("Vim", Class.new)
    api["classes"].each do |class_name|
      const_set(class_name, Class.new(Remote))
    end

    api["functions"].each do |func|
      class_name, method_name = func["name"].split("_", 2)
      class_name.capitalize!

      klass = const_get(class_name)
      klass.class_eval do
        define_method(method_name) do |*args|
          response = RPC.new([0, 0, func["id"], args], stream).response
          return_type = func["return_type"]

          if api["classes"].include?(return_type)
            raise "Can't return a #{return_type} yet."
          else
            response[3]
          end
        end
      end
    end

    true
  end
end
