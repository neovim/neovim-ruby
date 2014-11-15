require "helper"

RSpec.describe Neovim, :remote => true do
  it "conforms to the API returned from Neovim" do
    lib_root = File.expand_path("../../lib", __FILE__)
    functions = @client.rpc_send(:vim_get_api_info).fetch(1).fetch("functions")

    functions.each do |func_data|
      func_name = func_data["name"]
      next if func_name =~ /(subscribe|register)/
      match = %x(grep -Fr ':#{func_name}' #{lib_root})

      expect(match).not_to be_empty, "#{func_name} isn't implemented"
    end
  end
end
