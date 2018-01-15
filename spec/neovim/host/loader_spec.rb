require "helper"
require "neovim/host"

module Neovim
  class Host
    RSpec.describe Loader do
      describe "#load" do
        let(:plugin_path) { Support.file_path("plug.rb") }
        let(:host) { instance_double(Host, plugins: []) }
        let(:loader) { Loader.new(host) }

        before do
          File.write(plugin_path, "Neovim.plugin")
        end

        it "registers plugins defined in the provided files" do
          expect do
            loader.load([plugin_path])
          end.to change { host.plugins.size }.by(1)
        end

        it "registers multiple plugins defined in the provided files" do
          File.write(plugin_path, "Neovim.plugin; Neovim.plugin")

          expect do
            loader.load([plugin_path])
          end.to change { host.plugins.size }.by(2)
        end

        it "doesn't register plugins when none are defined" do
          File.write(plugin_path, "class FooClass; end")

          expect do
            loader.load([plugin_path])
          end.not_to change { host.plugins.size }
        end

        it "doesn't leak constants defined in plugins" do
          File.write(plugin_path, "class FooClass; end")

          expect do
            loader.load([plugin_path])
          end.not_to change { Kernel.const_defined?(:FooClass) }.from(false)
        end

        it "doesn't leak the overidden Neovim.plugin method" do
          loader.load([plugin_path])
          expect do
            Neovim.plugin
          end.to raise_error(/outside of a plugin host/)
        end
      end
    end
  end
end
