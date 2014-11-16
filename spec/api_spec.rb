require "helper"

RSpec.describe Neovim, :api do
  extend Support::Remote

  with_neovim_client do |client|
    lib_root = File.expand_path("../../lib", __FILE__)
    functions = client.rpc_send(:vim_get_api_info).fetch(1).fetch("functions")

    functions.each do |func_data|
      func_name = func_data["name"]

      it "implements #{func_name}" do
        match = %x(grep -Fr ':#{func_name}' #{lib_root})
        expect(match).to include(":#{func_name}")
      end
    end
  end
end
