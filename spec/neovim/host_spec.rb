require "helper"

module Neovim
  RSpec.describe Host do
    let(:manifest) { Host::Manifest.new }
    let(:host) { Host.new(manifest, double(:session)) }
    before { allow(Neovim).to receive(:plugin_host).and_return(host) }

    describe "#load_files" do
      it "registers defined plugins in its manifest" do
        plug1 = Support.file_path("plug1.rb")
        plug2 = Support.file_path("plug2.rb")

        File.write(plug1, "Neovim.plugin")
        File.write(plug2, "Neovim.plugin; Neovim.plugin")

        expect(manifest).to receive(:register).exactly(3).times
        host.load_files([plug1, plug2])
      end

      it "doesn't load plugin code into the global namespace" do
        plug = Support.file_path("plug.rb")
        File.write(plug, "class FooClass; end")

        host.load_files([plug])
        expect(Kernel.const_defined?("FooClass")).to be(false)
      end
    end

    describe "#run" do
      it "delegates messages to the manifest" do
        messages = []
        manifest = instance_double(Host::Manifest)
        session = Session.child(["nvim", "-n", "-u", "NONE"])

        host = Host.new(manifest, session)

        expect(manifest).to receive(:handle) do |msg, client|
          expect(msg.method_name).to eq("my_event")
          expect(msg.arguments).to eq(["arg"])
          expect(client).to be_a(Client)

          session.shutdown
        end

        session.request(:vim_subscribe, "my_event")
        session.request(:vim_command, "call rpcnotify(0, 'my_event', 'arg')")

        host.run
      end
    end
  end
end
