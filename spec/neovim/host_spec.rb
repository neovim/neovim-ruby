require "helper"
require "tempfile"

module Neovim
  RSpec.describe Host do
    describe ".load_from_files" do
      it "loads the defined plugins" do
        plug1 = ::Tempfile.open("plug1") do |f|
          f.write("Neovim.plugin")
          f.path
        end

        plug2 = ::Tempfile.open("plug2") do |f|
          f.write("Neovim.plugin; Neovim.plugin")
          f.path
        end

        host = Host.load_from_files([plug1, plug2])
        expect(host.plugins.size).to eq(3)
      end

      it "doesn't load plugin code into the global namespace" do
        plug = ::Tempfile.open("plug") do |f|
          f.write("class FooClass; end")
          f.path
        end

        host = Host.load_from_files([plug])
        expect(::Kernel.const_defined?("FooClass")).to be(false)
      end
    end
  end
end
