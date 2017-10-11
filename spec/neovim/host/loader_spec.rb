require "helper"
require "neovim/host"

module Neovim
  class Host
    RSpec.describe Loader do
      describe "#load" do
        let(:plugin_path) { Support.file_path("plug.rb") }
        let(:host) { instance_double(Host, :register => nil) }
        let(:loader) { Loader.new(host) }

        before do
          File.write(plugin_path, "Neovim.plugin")
        end

        it "registers plugins defined in the provided files" do
          expect(host).to receive(:register).with(kind_of(Plugin))
          loader.load([plugin_path])
        end

        it "registers multiple plugins defined in the provided files" do
          File.write(plugin_path, "Neovim.plugin; Neovim.plugin")
          expect(host).to receive(:register).with(kind_of(Plugin)).twice
          loader.load([plugin_path])
        end

        it "doesn't register plugins when none are defined" do
          File.write(plugin_path, "class FooClass; end")
          expect(host).not_to receive(:register)
          loader.load([plugin_path])
        end

        it "doesn't leak constants defined in plugins" do
          File.write(plugin_path, "class FooClass; end")
          loader.load([plugin_path])
          expect(Kernel.const_defined?(:FooClass)).to be(false)
        end

        it "doesn't leak the overidden Neovim.plugin method" do
          loader.load([plugin_path])
          expect {
            Neovim.plugin
          }.to raise_error(/outside of a plugin host/)
        end
      end
    end
  end
end
