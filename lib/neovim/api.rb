module Neovim
  class API
    # Represents an unknown API. Used as a stand-in when the API hasn't been
    # discovered yet via the +vim_get_api_info+ RPC call.
    #
    # @return [API]
    def self.null
      new([nil, {"functions" => [], "types" => []}])
    end

    def initialize(data)
      @data = data
    end

    # Return all functions defined by the API, as +Function+ objects.
    #
    # @return [Array<Function>]
    # @see Function
    def functions
      @functions ||= @data.fetch(1).fetch("functions").map do |func|
        Function.new(func["name"], func["async"])
      end
    end

    # Return information about +nvim+ types. Used for registering MessagePack
    # +ext+ types.
    #
    # @return [Hash]
    def types
      @types ||= @data.fetch(1).fetch("types")
    end

    # Return the channel ID of the current RPC session.
    #
    # @return [Fixnum, nil]
    def channel_id
      @channel_id ||= @data.fetch(0)
    end

    # Return a list of functions with the given name prefix.
    #
    # @param prefix [String] The function prefix
    # @return [Array<Function>]
    def functions_with_prefix(prefix)
      functions.select do |function|
        function.name =~ /\A#{prefix}/
      end
    end

    # Find a function with the given name.
    #
    # @param name [String] The name of the function
    # @return [Function, nil]
    def function(name)
      functions.find do |func|
        func.name == name.to_s
      end
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
