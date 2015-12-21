require "helper"
require "tempfile"

module Neovim
  RSpec.describe Host do
    describe ".load_from_files" do
      it "loads the defined plugins into a manifest" do
        plug1 = Tempfile.open("plug1") do |f|
          f.write("Neovim.plugin")
          f.path
        end

        plug2 = Tempfile.open("plug2") do |f|
          f.write("Neovim.plugin; Neovim.plugin")
          f.path
        end

        manifest = Manifest.new

        expect(manifest).to receive(:register).exactly(3).times
        host = Host.load_from_files([plug1, plug2], manifest)
        expect(host.manifest).to eq(manifest)
      end

      it "doesn't load plugin code into the global namespace" do
        plug = Tempfile.open("plug") do |f|
          f.write("class FooClass; end")
          f.path
        end

        host = Host.load_from_files([plug])
        expect(Kernel.const_defined?("FooClass")).to be(false)
      end
    end

    describe "#run" do
      # TODO: Find a way to test this without excessive mocking
    end
  end
end
