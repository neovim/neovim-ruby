require "helper"

module Neovim
  RSpec.describe APIInfo do
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
