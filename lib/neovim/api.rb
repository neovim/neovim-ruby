module Neovim
  class API
    def self.null
      new([nil, {"functions" => [], "types" => []}])
    end

    def initialize(data)
      @data = data
    end

    def functions
      @functions ||= @data.fetch(1).fetch("functions").map do |func|
        Function.new(func["name"], func["async"])
      end
    end

    def types
      @types ||= @data.fetch(1).fetch("types")
    end

    def channel_id
      @channel_id ||= @data.fetch(0)
    end

    def functions_with_prefix(prefix)
      functions.select do |function|
        function.name =~ /\A#{prefix}/
      end
    end

    def function(name)
      functions.find do |func|
        func.name == name.to_s
      end
    end

    def inspect
      "#<#{self.class}:0x%x @types={...} @functions={...}>" % (object_id << 1)
    end

    class Function < Struct.new(:name, :async)
      def call(session, *args)
        if async
          session.notify(name, *args)
        else
          session.request(name, *args)
        end
      end
    end
  end
end
