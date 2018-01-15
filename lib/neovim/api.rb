module Neovim
  # @api private
  class API
    attr_reader :channel_id

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
      format("#<#{self.class}:0x%x @channel_id=#{@channel_id.inspect}>", object_id << 1)
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

    # @api private
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
