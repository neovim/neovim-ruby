require "helper"

module Neovim
  class Session
    RSpec.describe API do
      describe ".null" do
        it "returns an empty API object" do
          api = API.null

          expect(api.types).to be_empty
          expect(api.functions).to be_empty
        end
      end

      describe "#function" do
        it "returns a sync function object" do
          api = API.new(
            [nil, {"functions" => [
              {"name" => "vim_sync", "async" => false}
            ]}]
          )

          function = api.function("vim_sync")
          expect(function.name).to eq("vim_sync")
          expect(function.async).to be(false)

          session = instance_double(Session)
          expect(session).to receive(:request).with("vim_sync", "msg")
          function.call(session, "msg")
        end

        it "returns an async function object" do
          api = API.new(
            [nil, {"functions" => [
              {"name" => "vim_async", "async" => true}
            ]}]
          )

          function = api.function("vim_async")
          expect(function.name).to eq("vim_async")
          expect(function.async).to be(true)

          session = instance_double(Session)
          expect(session).to receive(:notify).with("vim_async", "msg")
          function.call(session, "msg")
        end
      end

      describe "#functions_with_prefix" do
        it "returns relevant functions" do
          api = API.new(
            [nil, {"functions" => [
              {"name" => "vim_strwidth"},
              {"name" => "buffer_get_lines"}
            ]}]
          )

          functions = api.functions_with_prefix("vim_")
          expect(functions.size).to be(1)
          expect(functions.first.name).to eq("vim_strwidth")
        end
      end
    end
  end
end
