require "helper"

RSpec.describe Neovim do
  let(:client) { Support.persistent_client }

  let(:stream) do
    case Support.backend_strategy
    when /^tcp/, /^unix/
      "socket"
    else
      "stdio"
    end
  end

  describe ".attach" do
    it "sets appropriate client info" do
      chan_info = client.evaluate("nvim_get_chan_info(#{client.channel_id})")

      expect(chan_info).to match(
        "client" => {
          "name" => "ruby-client",
          "version" => {
            "major" => duck_type(:to_int),
            "minor" => duck_type(:to_int),
            "patch" => duck_type(:to_int)
          },
          "type" => "remote",
          "methods" => {},
          "attributes" => duck_type(:to_hash)
        },
        "id" => duck_type(:to_int),
        "mode" => "rpc",
        "stream" => stream
      )
    end
  end

  describe ".executable" do
    it "returns the current executable" do
      expect(Neovim.executable).to be_a(Neovim::Executable)
    end
  end
end
