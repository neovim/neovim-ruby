require "json"
require "net/http"
require "uri"

RSpec.describe "neovim-ruby documentation" do
  it "has up-to-date generated method docs" do
    begin
      latest_release_uri = URI.parse(
        "https://api.github.com/repos/neovim/neovim/releases/latest"
      )
      response = JSON.parse(
        Net::HTTP.get_response(latest_release_uri).body
      )
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
