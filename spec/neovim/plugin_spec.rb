require "helper"

module Neovim
  RSpec.describe Plugin do
    describe ".from_config_block" do
      it "registers a request handler" do
        calls = []

        plugin = Plugin.from_config_block do |plug|
          plug.on_request do |*args|
            calls << args
          end
        end

        expect {
          plugin.request_handler.call(:foo, :bar)
        }.to change { calls }.to([[:foo, :bar]])
      end

      it "registers a notification handler" do
        calls = []

        plugin = Plugin.from_config_block do |plug|
          plug.on_notification do |method, args|
            calls << [method, args]
          end
        end

        expect {
          plugin.notification_handler.call(:foo, :bar)
        }.to change { calls }.to([[:foo, :bar]])
      end
    end
  end
end
