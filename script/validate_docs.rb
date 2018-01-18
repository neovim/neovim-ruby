#!/usr/bin/env ruby

require "json"
require "open-uri"

url = "https://api.github.com/repos/neovim/neovim/releases/latest"

begin
  response = open(url) { |res| JSON.parse(res.read) }
rescue SocketError, OpenURI::HTTPError => e
  puts "Request failed: #{e}\n"
  exit
end

release_version = response["name"][/NVIM v?(.+)$/, 1]

client_file = File.read(
  File.expand_path("../../lib/neovim/client.rb", __FILE__)
)
docs_version = client_file[
  /The methods documented here were generated using NVIM v?(.+)$/,
  1
]

if docs_version == release_version
  puts "Documentation is up-to-date."
else
  abort "Documentation is out of date: expected #{release_version}, got #{docs_version}."
end
