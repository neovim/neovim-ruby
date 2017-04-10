require "json"
require "net/http"
require "open-uri"

RSpec.describe "neovim-ruby documentation" do
  it "has up-to-date generated method docs" do
    begin
      url = "https://api.github.com/repos/neovim/neovim/releases/latest"
      response = open(url) { |json| JSON.load(json) }

      client_file = File.read(
        File.expand_path("../../../lib/neovim/client.rb", __FILE__)
      )
      docs_version = client_file[
        /The methods documented here were generated using (.+)$/,
        1
      ]

      expect(docs_version).to eq(response["name"])
    rescue SocketError => e
      skip "Skipping: #{e}"
    end
  end
end
