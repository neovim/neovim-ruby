module Neovim
  class Session
    # @api private
    class API
      attr_reader :channel_id

      # Represents an unknown API. Used as a stand-in when the API hasn't been
      # discovered yet via the +vim_get_api_info+ RPC call.
      def self.null
        new([nil, {"functions" => [], "types" => []}])
      end

      def initialize(payload)
        @channel_id, @api_info = payload
      end

      # Return all functions defined by the API.
      def functions
        @functions ||= @api_info.fetch("functions").inject({}) do |acc, func|
          name, async = func.values_at("name", "async")
          acc.merge(name => Function.new(name, async))
        end
      end

      # Return information about +nvim+ types. Used for registering MessagePack
      # +ext+ types.
      def types
        @types ||= @api_info.fetch("types")
      end

      # Return a list of functions with the given name prefix.
      def functions_with_prefix(prefix)
        functions.inject([]) do |acc, (name, function)|
          name =~ /\A#{prefix}/ ? acc.push(function) : acc
        end
      end

      # Find a function with the given name.
      def function(name)
        functions[name.to_s]
      end

      # Truncate the output of inspect so console sessions are more pleasant.
      def inspect
        "#<#{self.class}:0x%x @types={...} @functions={...}>" % (object_id << 1)
      end

      class Function
        attr_reader :name, :async

        def initialize(name, async)
          @name, @async = name, async
        end

        # Apply this function to a running RPC session. Sends either a request if
        # +async+ is +false+ or a notification if +async+ is +true+.
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
end
