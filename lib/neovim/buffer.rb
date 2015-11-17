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

      def [](idx, len=nil)
        case idx
        when Range
          @buffer.get_line_slice(idx.begin, idx.end, true, !idx.exclude_end?)
        else
          if len
            @buffer.get_line_slice(idx, idx + len, true, false)
          else
            @buffer.get_line(idx)
          end
        end
      end
      alias_method :slice, :[]

      def []=(*args)
        *target, val = args
        idx, len = target

        case idx
        when Range
          @buffer.set_line_slice(
            idx.begin,
            idx.end,
            true,
            !idx.exclude_end?,
            val
          )
        else
          if len
            @buffer.set_line_slice(idx, idx + len, true, false, val)
          else
            @buffer.set_line(idx, val)
          end
        end
      end
    end
  end
end
