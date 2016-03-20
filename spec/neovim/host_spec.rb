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
      it "delegates messages to the manifest" do
        messages = []
        manifest = instance_double(Manifest)

        event_loop = EventLoop.child(["-n", "-u", "NONE"])
        msgpack_stream = MsgpackStream.new(event_loop)
        async_session = AsyncSession.new(msgpack_stream)
        session = Session.new(async_session)

        host = Host.new(manifest, session)

        expect(manifest).to receive(:handle) do |msg, client|
          expect(msg.method_name).to eq("my_event")
          expect(msg.arguments).to eq(["arg"])
          expect(client).to be_a(Client)

          session.stop
        end

        session.request(:vim_subscribe, "my_event")
        session.request(:vim_command, "call rpcnotify(0, 'my_event', 'arg')")

        host.run
      end
    end
  end
end
