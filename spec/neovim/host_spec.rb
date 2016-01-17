require "helper"

module Neovim
  RSpec.describe Host do
    describe ".load_from_files" do
      it "loads the defined plugins into a manifest" do
        plug1 = Support.file_path("plug1.rb")
        plug2 = Support.file_path("plug2.rb")

        File.write(plug1, "Neovim.plugin")
        File.write(plug2, "Neovim.plugin; Neovim.plugin")

        manifest = Manifest.new

        expect(manifest).to receive(:register).exactly(3).times
        host = Host.load_from_files([plug1, plug2], manifest)
        expect(host.manifest).to eq(manifest)
      end

      it "doesn't load plugin code into the global namespace" do
        plug = Support.file_path("plug.rb")
        File.write(plug, "class FooClass; end")

        host = Host.load_from_files([plug])
        expect(Kernel.const_defined?("FooClass")).to be(false)
      end
    end

    describe "#run" do
      # TODO: Find a way to test this without excessive mocking
    end
  end
end
