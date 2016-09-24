require "helper"
require "neovim/host"

module Neovim
  RSpec.describe Host do
    let(:session) { instance_double(Session) }
    let(:client) { instance_double(Client) }
    let(:host) { Host.new(session, client) }

    describe ".run" do
      it "loads plugins and runs the host event loop" do
        paths = ["/foo", "/bar"]

        expect(Host).to receive(:new).and_return(host)
        expect(host).to receive(:run)

        loader = instance_double(Host::Loader)

        expect(loader).to receive(:load).with(paths)
        expect(Host::Loader).to receive(:new).
          with(host).
          and_return(loader)

        Host.run(paths, :session => session, :client => client)
      end
    end

    describe "#run" do
      it "runs the session event loop and handles messages" do
        message = double(:message)
        expect(session).to receive(:run).and_yield(message)
        expect(host).to receive(:handle).with(message)

        host.run
      end

      it "rescues session exceptions" do
        expect(session).to receive(:run).and_raise("BOOM")
        expect { host.run }.not_to raise_error
      end
    end

    describe "#handlers" do
      it "has a default poll handler" do
        expect(host.handlers["poll"]).to respond_to(:call)
      end
    end

    describe "#specs" do
      it "has default specs" do
        expect(host.specs).to eq({})
      end
    end

    describe "#register" do
      it "adds specs" do
        plugin = Plugin.from_config_block("source") do |plug|
          plug.command(:Foo)
        end

        expect {
          host.register(plugin)
        }.to change { host.specs }.from({}).to("source" => plugin.specs)
      end

      it "adds plugin handlers" do
        plugin = Plugin.from_config_block("source") do |plug|
          plug.command(:Foo)
        end

        expect {
          host.register(plugin)
        }.to change {
          host.handlers["source:command:Foo"]
        }.from(nil).to(kind_of(Proc))
      end

      it "doesn't add top-level RPCs to specs" do
        plugin = Plugin.from_config_block("source") do |plug|
          plug.__send__(:rpc, :Foo)
        end

        expect {
          host.register(plugin)
        }.to change { host.specs }.from({}).to("source" => [])
      end
    end

    describe "#handle" do
      it "calls the poll handler" do
        message = double(:message, :method_name => "poll", :sync? => true)

        expect(message).to receive(:respond).with("ok")
        host.handle(message)
      end

      it "calls the specs handler" do
        plugin = Plugin.from_config_block("source") do |plug|
          plug.command(:Foo)
        end
        host.register(plugin)

        message = double(:message, :method_name => "specs", :sync? => true, :arguments => ["source"])

        expect(message).to receive(:respond).with(plugin.specs)
        host.handle(message)
      end

      it "calls a plugin sync handler" do
        plugin = Plugin.from_config_block("source") do |plug|
          plug.command(:Foo, :sync => true) { |client, arg| [client, arg] }
        end
        host.register(plugin)

        message = double(:message, :method_name => "source:command:Foo", :sync? => true, :arguments => [:arg])

        expect(message).to receive(:respond).with([client, :arg])
        host.handle(message)
      end

      it "rescues plugin sync handler exceptions" do
        plugin = Plugin.from_config_block("source") do |plug|
          plug.command(:Foo, :sync => true) { raise "BOOM" }
        end
        host.register(plugin)

        message = double(:message, :method_name => "source:command:Foo", :sync? => true, :arguments => [])

        expect(message).to receive(:error).with("BOOM")
        host.handle(message)
      end

      it "calls a plugin async handler" do
        async_proc = Proc.new {}
        plugin = Plugin.from_config_block("source") do |plug|
          plug.command(:Foo, &async_proc)
        end
        host.register(plugin)

        message = double(:message, :method_name => "source:command:Foo", :sync? => false, :arguments => [:arg])

        expect(async_proc).to receive(:call).with(client, :arg)
        host.handle(message)
      end

      it "calls a default sync handler" do
        message = double(:message, :method_name => "foobar", :sync? => true)

        expect(message).to receive(:error).with("Unknown request foobar")
        host.handle(message)
      end

      it "calls a default async handler" do
        message = double(:message, :method_name => "foobar", :sync? => false)

        host.handle(message)
      end
    end
  end
end
