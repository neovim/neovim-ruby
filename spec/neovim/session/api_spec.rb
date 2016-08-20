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
        it "returns a corresponding Function object" do
          api = API.new(
            [nil, {"functions" => [
              {"name" => "vim_strwidth", "async" => false}
            ]}]
          )

          function = api.function("vim_strwidth")
          expect(function).to be_a(API::Function)
          expect(function.name).to eq("vim_strwidth")
          expect(function.async).to be(false)
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
