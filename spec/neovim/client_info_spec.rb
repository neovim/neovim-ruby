require "neovim/client_info"
require "neovim/host"
require "neovim/plugin"

module Neovim
  RSpec.describe ClientInfo do
    describe "#to_args" do
      context ".for_host" do
        it "returns script-host info" do
          plugin = double(Plugin, script_host?: true)
          host = double(Host, plugins: [plugin])
          info = ClientInfo.for_host(host)

          expect(info.to_args).to match(
            [
              "ruby-script-host",
              {
                "major" => duck_type(:to_int),
                "minor" => duck_type(:to_int),
                "patch" => duck_type(:to_int)
              },
              :host,
              {
                poll: {},
                specs: {nargs: 1}
              },
              duck_type(:to_hash)
            ]
          )
        end

        it "returns rplugin info" do
          plugin = double(Plugin, script_host?: false)
          host = double(Host, plugins: [plugin])
          info = ClientInfo.for_host(host)

          expect(info.to_args).to match(
            [
              "ruby-rplugin-host",
              {
                "major" => duck_type(:to_int),
                "minor" => duck_type(:to_int),
                "patch" => duck_type(:to_int)
              },
              :host,
              {
                poll: {},
                specs: {nargs: 1}
              },
              duck_type(:to_hash)
            ]
          )
        end
      end

      context ".for_client" do
        it "returns remote client info" do
          info = ClientInfo.for_client

          expect(info.to_args).to match(
            [
              "ruby-client",
              {
                "major" => duck_type(:to_int),
                "minor" => duck_type(:to_int),
                "patch" => duck_type(:to_int)
              },
              :remote,
              {},
              duck_type(:to_hash)
            ]
          )
        end
      end
    end
  end
end
