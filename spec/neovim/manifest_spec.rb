require "helper"

module Neovim
  RSpec.describe Manifest do
    it "has a default poll handler" do
      manifest = Manifest.new
      expect(manifest.handlers["poll"]).to respond_to(:call)
    end

    it "has default specs" do
      manifest = Manifest.new
      expect(manifest.specs).to eq({})
    end

    describe "#register" do
      it "adds specs" do
        manifest = Manifest.new

        plugin = Plugin.from_config_block("source") do |plug|
          plug.command(:Foo)
        end

        expect {
          manifest.register(plugin)
        }.to change { manifest.specs }.from({}).to("source" => plugin.specs)
      end

      it "adds plugin handlers" do
        manifest = Manifest.new

        plugin = Plugin.from_config_block("source") do |plug|
          plug.command(:Foo)
        end

        expect {
          manifest.register(plugin)
        }.to change {
          manifest.handlers["source:command:Foo"]
        }.from(nil).to(kind_of(Proc))
      end

      it "doesn't add top-level RPCs to specs" do
        manifest = Manifest.new

        plugin = Plugin.from_config_block("source") do |plug|
          plug.rpc(:Foo)
        end

        expect {
          manifest.register(plugin)
        }.to change { manifest.specs }.from({}).to("source" => [])
      end
    end

    describe "#handle" do
      it "calls the poll handler" do
        manifest = Manifest.new
        message = double(:message, :method_name => "poll", :sync? => true)
        client = double(:client)

        expect(message).to receive(:respond).with("ok")
        manifest.handle(message, client)
      end

      it "calls the specs handler" do
        manifest = Manifest.new
        plugin = Plugin.from_config_block("source") do |plug|
          plug.command(:Foo)
        end
        manifest.register(plugin)

        message = double(:message, :method_name => "specs", :sync? => true, :arguments => ["source"])

        expect(message).to receive(:respond).with(plugin.specs)
        manifest.handle(message, double(:client))
      end

      it "calls a plugin sync handler" do
        manifest = Manifest.new
        plugin = Plugin.from_config_block("source") do |plug|
          plug.command(:Foo, :sync => true) { |client, arg| [client, arg] }
        end
        manifest.register(plugin)

        message = double(:message, :method_name => "source:command:Foo", :sync? => true, :arguments => [:arg])
        client = double(:client)

        expect(message).to receive(:respond).with([client, :arg])
        manifest.handle(message, client)
      end

      it "rescues plugin sync handler exceptions" do
        manifest = Manifest.new
        plugin = Plugin.from_config_block("source") do |plug|
          plug.command(:Foo, :sync => true) { raise "BOOM" }
        end
        manifest.register(plugin)

        message = double(:message, :method_name => "source:command:Foo", :sync? => true, :arguments => [])
        client = double(:client)

        expect(message).to receive(:error).with("BOOM")
        manifest.handle(message, client)
      end

      it "calls a plugin async handler" do
        manifest = Manifest.new
        async_proc = Proc.new {}
        plugin = Plugin.from_config_block("source") do |plug|
          plug.command(:Foo, &async_proc)
        end
        manifest.register(plugin)

        message = double(:message, :method_name => "source:command:Foo", :sync? => false, :arguments => [:arg])
        client = double(:client)

        expect(async_proc).to receive(:call).with(client, :arg)
        manifest.handle(message, client)
      end

      it "calls a default sync handler" do
        manifest = Manifest.new
        message = double(:message, :method_name => "foobar", :sync? => true)

        expect(message).to receive(:error).with("Unknown request foobar")
        manifest.handle(message, double(:client))
      end

      it "calls a default async handler" do
        manifest = Manifest.new
        message = double(:message, :method_name => "foobar", :sync? => false)

        manifest.handle(message, double(:client))
      end
    end
  end
end
