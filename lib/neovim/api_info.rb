module Neovim
  class APIInfo
    def self.null
      new([nil, {"functions" => [], "types" => []}])
    end

    def initialize(data)
      @data = data
    end

    def functions
      @functions ||= @data.fetch(1).fetch("functions")
    end

    def types
      @types ||= @data.fetch(1).fetch("types")
    end

    def channel_id
      @channel_id ||= @data.fetch(0)
    end

    def defined?(function)
      functions.any? do |func|
        func["name"] == function.to_s
      end
    end

    def functions_with_prefix(prefix)
      functions.inject([]) do |acc, function|
        if function["name"] =~ /\A#{prefix}/
          acc + [function["name"].sub(/\A#{prefix}/, "").to_sym]
        else
          acc
        end
      end
    end

    def inspect
      "#<#{self.class}:0x%x @types={...} @functions={...}>" % (object_id << 1)
    end
  end
end
