require "helper"
require "neovim/manifest"
require "neovim/plugin"

module Neovim
  RSpec.describe Manifest do
    describe ".load_from_plugins" do
      it "loads sync handlers" do
        plugin = Plugin.from_config_block do |plug|
          plug.command(:Foo, :sync => true) do |client, *args|
            [client, args]
          end
        end

        mock_client = double(:client)
        mock_req = double(:request, :arguments => [])
        manifest = Manifest.load_from_plugins([plugin])

        expect(mock_req).to receive(:respond).with([mock_client, []])
        manifest.handlers[:sync][:Foo].call(mock_client, mock_req)
      end

      it "loads async handlers" do
        plugin = Plugin.from_config_block do |plug|
          plug.command(:Foo, :sync => false) do |client, *args|
            [client, args]
          end
        end

        mock_client = double(:client)
        mock_ntf = double(:notification, :arguments => [])
        manifest = Manifest.load_from_plugins([plugin])

        result = manifest.handlers[:async][:Foo].call(mock_client, mock_ntf)
        expect(result).to eq([mock_client, []])
      end

      it "loads the poll handler" do
        mock_client = double(:client)
        mock_req = double(:request, :arguments => [])
        manifest = Manifest.load_from_plugins([Plugin.new])

        expect(mock_req).to receive(:respond).with("ok")
        manifest.handlers[:sync][:poll].call(mock_client, mock_req)
      end

      it "loads the default request handler" do
        mock_client = double(:client)
        mock_req = double(:request, :method_name => :foobar, :arguments => [])
        manifest = Manifest.load_from_plugins([Plugin.new])

        expect(mock_req).to receive(:error)
        manifest.handlers[:sync][:foobar].call(mock_client, mock_req)
      end

      it "loads the default no-op notification handler" do
        mock_client = double(:client)
        mock_ntf = double(:notification)
        manifest = Manifest.load_from_plugins([Plugin.new])

        manifest.handlers[:async][:foobar].call(mock_client, mock_ntf)
      end
    end

    describe "#handle_request" do
      it "delegates to the appropriate sync handler" do
        req_cb = Proc.new {}
        mock_client = double(:client)
        mock_req = double(:request, :method_name => :foo)
        handlers = {:sync => {:foo => req_cb}}

        manifest = Manifest.new(handlers)
        expect(req_cb).to receive(:call).with(mock_client, mock_req)
        manifest.handle_request(mock_req, mock_client)
      end
    end

    describe "#handle_notification" do
      it "delegates to the appropriate async handler" do
        ntf_cb = Proc.new {}
        mock_client = double(:client)
        mock_ntf = double(:notification, :method_name => :foo)
        handlers = {:async => {:foo => ntf_cb}}

        manifest = Manifest.new(handlers)
        expect(ntf_cb).to receive(:call).with(mock_client, mock_ntf)
        manifest.handle_notification(mock_ntf, mock_client)
      end
    end
  end
end
