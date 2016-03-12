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

    describe "#functions_with_prefix" do
      it "returns relevant functions without a prefix" do
        api = APIInfo.new(
          [nil, {"functions" => [{"name" => "vim_strwidth"}]}]
        )

        methods = api.functions_with_prefix("vim_")
        expect(methods).to eq([:strwidth])
      end
    end
  end
end
