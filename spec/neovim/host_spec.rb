require "helper"
require "tempfile"

module Neovim
  RSpec.describe Host do
    describe ".load_from_files" do
      it "loads the defined plugins" do
        plug1 = Tempfile.open("plug1") do |f|
          f.write("Neovim.plugin")
          f.path
        end

        plug2 = Tempfile.open("plug2") do |f|
          f.write("Neovim.plugin; Neovim.plugin")
          f.path
        end

        host = Host.load_from_files([plug1, plug2])
        expect(host.plugins.size).to eq(3)
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

    describe "#handlers" do
      it "includes a poll callback" do
        host = Host.new([Plugin.new])
        expect(host.handlers[:request]).to include(:poll => kind_of(Proc))
      end

      it "includes request callbacks" do
        plugin = Plugin.from_config_block do |plug|
          plug.command("Foo", :sync => true)
        end

        host = Host.new([plugin])
        expect(host.handlers[:request]).to include(:Foo => kind_of(Proc))
      end

      it "includes notification callbacks" do
        plugin = Plugin.from_config_block do |plug|
          plug.command("Foo", :sync => false)
        end

        host = Host.new([plugin])
        expect(host.handlers[:notification]).to include(:Foo => kind_of(Proc))
      end
    end

    describe "#run" do
      it "runs an async client with the plugins as callbacks" do
        sync_cb = lambda { |nvim, x, y| [nvim, x, y] }
        async_cb = lambda { |nvim, x, y| [nvim, x, y] }

        plugin = Plugin.from_config_block do |plug|
          plug.command(:Sync, :nargs => 2, :sync => true, &sync_cb)
          plug.command(:Async, :nargs => 2, &async_cb)
        end

        mock_async_session = double(:async_session, :request => nil)
        expect(AsyncSession).to receive(:new) { mock_async_session }

        mock_client = double(:client)
        expect(Client).to receive(:new) { mock_client }

        expect(EventLoop).to receive(:stdio) { double(:event_loop) }
        expect(MsgpackStream).to receive(:new) { double(:msgpack_stream) }
        expect(Session).to receive(:new) { double(:session) }

        expect(mock_async_session).to receive(:run) do |req_cb, not_cb|
          mock_request = double(
            :request,
            :method_name => :Sync,
            :arguments => [1, 2]
          )

          mock_notification = double(
            :notification,
            :method_name => :Async,
            :arguments => [3, 4]
          )

          expect(sync_cb).to receive(:call).with(mock_client, 1, 2).and_call_original
          expect(mock_request).to receive(:respond).with([mock_client, 1, 2])
          req_cb.call(mock_request)

          expect(async_cb).to receive(:call).with(mock_client, 3, 4).and_call_original
          not_cb.call(mock_notification)
        end

        host = Host.new([plugin])
        host.run
      end
    end
  end
end
