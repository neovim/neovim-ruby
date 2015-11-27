require "delegate"

module Neovim
  class APIInfo < SimpleDelegator
    def functions
      @functions ||= fetch(1).fetch("functions")
    end

    def types
      @types ||= fetch(1).fetch("types")
    end

    def channel_id
      @channel_id ||= fetch(0)
    end

    def defined?(function)
      functions.any? do |func|
        func["name"] == function.to_s
      end
    end

    def inspect
      "#<#{self.class}:0x%x @types={...} @functions={...}>" % (object_id << 1)
    end
  end
end
