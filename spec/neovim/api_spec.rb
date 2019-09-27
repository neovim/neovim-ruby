require "helper"

module Neovim
  RSpec.describe API do
    let(:client) { Support.persistent_client }

    let(:api) do
      API.new(
        [
          nil,
          {
            "functions" => [
              {"name" => "nvim_func"},
              {"name" => "nvim_buf_func"},
              {"name" => "nvim_win_func"},
              {"name" => "nvim_tabpage_func"}
            ]
          }
        ]
      )
    end

    describe "#functions_for_object_method" do
      it "returns relevant functions" do
        function = api.function_for_object_method(client, :func)
        expect(function.name).to eq("nvim_func")

        function = api.function_for_object_method(client.get_current_buf, :func)
        expect(function.name).to eq("nvim_buf_func")

        function = api.function_for_object_method(client.get_current_win, :func)
        expect(function.name).to eq("nvim_win_func")

        function = api.function_for_object_method(client.get_current_tabpage, :func)
        expect(function.name).to eq("nvim_tabpage_func")
      end
    end

    describe "#functions_for_object" do
      it "returns relevant functions" do
        functions = api.functions_for_object(client)
        expect(functions.size).to be(1)
        expect(functions.first.name).to eq("nvim_func")

        functions = api.functions_for_object(client.get_current_buf)
        expect(functions.size).to be(1)
        expect(functions.first.name).to eq("nvim_buf_func")

        functions = api.functions_for_object(client.get_current_win)
        expect(functions.size).to be(1)
        expect(functions.first.name).to eq("nvim_win_func")

        functions = api.functions_for_object(client.get_current_tabpage)
        expect(functions.size).to be(1)
        expect(functions.first.name).to eq("nvim_tabpage_func")
      end
    end
  end
end
