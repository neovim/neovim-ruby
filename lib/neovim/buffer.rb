require "neovim/object"

module Neovim
  class Buffer < Neovim::Object
    def lines
      @lines ||= Lines.new(self)
    end

    def lines=(arr)
      lines[0..-1] = arr
    end

    class Lines
      include Enumerable

      def initialize(buffer)
        @buffer = buffer
      end

      def ==(other)
        case other
        when Array
          to_a == other
        else
          super
        end
      end

      def to_a
        self[0..-1]
      end

      def each(&block)
        to_a.each(&block)
      end

      def [](obj, len=nil)
        case obj
        when Range
          @buffer.get_line_slice(obj.begin, obj.end, true, !obj.exclude_end?)
        else
          if len
            @buffer.get_line_slice(obj, obj + len, true, false)
          else
            @buffer.get_line(obj)
          end
        end
      end
      alias_method :slice, :[]

      def []=(*_args)
        args = _args.dup
        repl = args.pop
        obj, len = args

        case obj
        when Range
          @buffer.set_line_slice(
            obj.begin,
            obj.end,
            true,
            !obj.exclude_end?,
            Array(repl)
          )
        else
          if len
            @buffer.set_line_slice(obj, obj + len, true, false, Array(repl))
          else
            @buffer.set_line(obj, repl)
          end
        end
      end
    end
  end
end
