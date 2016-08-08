module Neovim
  # @api private
  class API
    attr_reader :channel_id

    # Represents an unknown API. Used as a stand-in when the API hasn't been
    # discovered yet via the +vim_get_api_info+ RPC call.
    #
    # @return [API]
    def self.null
      new([nil, {"functions" => [], "types" => []}])
    end

    def initialize(api_info)
      @channel_id, @api_info = api_info
    end

    # Return all functions defined by the API.
    #
    # @return [Hash{String => Function}] A +Hash+ mapping function names to
    #   +Function+ objects.
    # @see Function
    def functions
      @functions ||= @api_info.fetch("functions").inject({}) do |acc, func|
        name, async = func.values_at("name", "async")
        acc.merge(name => Function.new(name, async))
      end
    end

    # Return information about +nvim+ types. Used for registering MessagePack
    # +ext+ types.
    #
    # @return [Hash]
    def types
      @types ||= @api_info.fetch("types")
    end

    # Return a list of functions with the given name prefix.
    #
    # @param prefix [String] The function prefix
    # @return [Array<Function>]
    def functions_with_prefix(prefix)
      functions.inject([]) do |acc, (name, function)|
        name =~ /\A#{prefix}/ ? acc.push(function) : acc
      end
    end

    # Find a function with the given name.
    #
    # @param name [String] The name of the function
    # @return [Function, nil]
    def function(name)
      functions[name.to_s]
    end

    # Truncate the output of inspect so console sessions are more pleasant.
    #
    # @return [String]
    def inspect
      "#<#{self.class}:0x%x @types={...} @functions={...}>" % (object_id << 1)
    end

    # Encapsulate an RPC function.
    class Function < Struct.new(:name, :async)
      # Apply this function to a running RPC session. Sends either a request if
      # +async+ is +false+ or a notification if +async+ is +true+.
      #
      # @param session [Session] The session to apply the function to.
      # @param *args [Array] Arguments to the function.
      # @return [Object, nil]
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
