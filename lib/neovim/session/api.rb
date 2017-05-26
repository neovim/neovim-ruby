module Neovim
  class Session
    # @api private
    class API
      attr_reader :channel_id

      # Represents an unknown API. Used as a stand-in when the API hasn't been
      # discovered yet via the +nvim_get_api_info+ RPC call.
      def self.null
        new([nil, {"functions" => [], "types" => []}])
      end

      def initialize(payload)
        @channel_id, @api_info = payload
      end

      # Return all functions defined by the API.
      def functions
        @functions ||= @api_info.fetch("functions").inject({}) do |acc, func|
          function = Function.new(func)
          acc.merge(function.name => function)
        end
      end

      # Return information about +nvim+ types. Used for registering MessagePack
      # +ext+ types.
      def types
        @types ||= @api_info.fetch("types")
      end

      def function_for_object_method(obj, method_name)
        functions[function_name(obj, method_name)]
      end

      def functions_for_object(obj)
        pattern = function_pattern(obj)
        functions.values.select { |func| func.name =~ pattern }
      end

      # Truncate the output of inspect so console sessions are more pleasant.
      def inspect
        "#<#{self.class}:0x%x @channel_id=#{@channel_id.inspect} @types={...} @functions={...}>" % (object_id << 1)
      end

      private

      def function_name(obj, method_name)
        case obj
        when Client
          "nvim_#{method_name}"
        when Buffer
          "nvim_buf_#{method_name}"
        when Window
          "nvim_win_#{method_name}"
        when Tabpage
          "nvim_tabpage_#{method_name}"
        else
          raise "Unknown object #{obj.inspect}"
        end
      end

      def function_pattern(obj)
        case obj
        when Client
          /^nvim_(?!(buf|win|tabpage)_)/
        when Buffer
          /^nvim_buf_/
        when Window
          /^nvim_win_/
        when Tabpage
          /^nvim_tabpage_/
        else
          raise "Unknown object #{obj.inspect}"
        end
      end

      class Function
        attr_reader :name

        def initialize(attributes)
          @name = attributes.fetch("name")
        end

        def method_name
          @name.sub(/^nvim_(win_|buf_|tabpage_)?/, "").to_sym
        end

        # Apply this function to a running RPC session.
        def call(session, *args)
          session.request(name, *args)
        end
      end
    end
  end
end
