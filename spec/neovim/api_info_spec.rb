require "helper"

module Neovim
  RSpec.describe APIInfo do
    describe ".null" do
      it "returns an empty APIInfo object" do
        api = APIInfo.null

        expect(api.types).to eq([])
        expect(api.functions).to eq([])
      end
    end

    describe "#function" do
      it "returns a corresponding Function object" do
        api = APIInfo.new(
          [nil, {"functions" => [
            {"name" => "vim_strwidth", "async" => false}
          ]}]
        )

        function = api.function("vim_strwidth")
        expect(function).to be_a(APIInfo::Function)
        expect(function.name).to eq("vim_strwidth")
        expect(function.async).to be(false)
      end
    end

    describe "#functions_with_prefix" do
      it "returns relevant functions" do
        api = APIInfo.new(
          [nil, {"functions" => [{"name" => "vim_strwidth"}]}]
        )

        functions = api.functions_with_prefix("vim_")
        expect(functions.first.name).to eq("vim_strwidth")
      end
    end
  end
end
