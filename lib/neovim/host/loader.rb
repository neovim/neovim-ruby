require "neovim/plugin"

module Neovim
  class Host
    # @api private
    class Loader
      def initialize(host)
        @host = host
      end

      # Load the provided Ruby files while temporarily overriding
      # +Neovim.plugin+ to expose the remote plugin DSL and register the result
      # to the host.
      def load(paths)
        paths.each do |path|
          override_plugin_method(path) do
            Kernel.load(path, true)
          end
        end
      end

      private

      def override_plugin_method(path)
        old_plugin_def = Neovim.method(:plugin)
        at_host = @host

        Neovim.define_singleton_method(:plugin) do |&block|
          plugin = Plugin.from_config_block(path, &block)
          at_host.register(plugin)
        end

        yield
      ensure
        Neovim.define_singleton_method(:plugin, &old_plugin_def)
      end
    end
  end
end
