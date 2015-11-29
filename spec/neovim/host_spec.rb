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

        mock_manifest = double(:manifest)
        expect(Manifest).to receive(:load_from_plugins) do |plugs|
          expect(plugs.size).to be(3)
          mock_manifest
        end

        host = Host.load_from_files([plug1, plug2])
        expect(host.manifest).to eq(mock_manifest)
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
