require "neovim/object"

module Neovim
  class Window < Neovim::Object
    def cursor
      @cursor ||= Cursor.new(self)
    end

    class Cursor
      def initialize(window)
        @window = window
      end

      def coordinates
        @window.get_cursor
      end

      def coordinates=(coords)
        @window.set_cursor(coords)
      end

      def line
        coordinates[0]
      end

      def line=(n)
        self.coordinates = [n, column]
      end

      def column
        coordinates[1]
      end

      def column=(n)
        self.coordinates = [line, n]
      end
    end
  end
end
