module Neovim
  class Plugin
    # @api private
    class Handler
      attr_reader :block

      def self.unqualified(name, block)
        new(nil, nil, name, true, {qualified: false}, block)
      end

      def initialize(source, type, name, sync, options, block)
        @source = source
        @type = type.to_sym if type.respond_to?(:to_sym)
        @name = name.to_s
        @sync = sync
        @options = options
        @block = block || -> {}
        @qualified =
          options.key?(:qualified) ? options.delete(:qualified) : true
      end

      def sync?
        !!@sync
      end

      def qualified?
        @qualified
      end

      def qualified_name
        return @name unless qualified?

        if @type == :autocmd
          pattern = @options.fetch(:pattern, "*")
          "#{@source}:#{@type}:#{@name}:#{pattern}"
        else
          "#{@source}:#{@type}:#{@name}"
        end
      end

      def to_spec
        {
          type: @type,
          name: @name,
          sync: @sync,
          opts: @options
        }
      end

      def call(*args)
        @block.call(*args)
      end
    end
  end
end
