module Neovim
  class Plugin
    # @api private
    class Handler
      attr_reader :block

      def initialize(source, type, name, sync, options, block)
        @source = source
        @type = type.to_sym
        @name = name.to_s
        @sync = !!sync
        @options = options
        @block = block || Proc.new {}
      end

      def qualified_name
        if @type == :autocmd
          pattern = @options.fetch(:pattern, "*")
          "#{@source}:#{@type}:#{@name}:#{pattern}"
        else
          "#{@source}:#{@type}:#{@name}"
        end
      end

      def sync?
        @sync
      end

      def to_spec
        {
          :type => @type,
          :name => @name,
          :sync => @sync,
          :opts => @options,
        }
      end

      def call(*args)
        @block.call(*args)
      end
    end
  end
end
