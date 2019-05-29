require "helper"

RSpec.describe Neovim do
  shared_context "attached client" do
    it "establishes an RPC connection" do
      expect(client.strwidth("hi")).to eq(2)
    end

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

  describe ".attach_tcp" do
    include_context "attached client" do
      let(:port) { Support.tcp_port }
      let(:stream) { "socket" }

      let!(:nvim_pid) do
        env = {"NVIM_LISTEN_ADDRESS" => "127.0.0.1:#{port}"}
        Process.spawn(env, *Support.child_argv, [:out, :err] => File::NULL)
      end

      let(:client) do
        begin
          Neovim.attach_tcp("127.0.0.1", port)
        rescue Errno::ECONNREFUSED
          retry
        end
      end

      after { Support.kill(nvim_pid) }
    end
  end

  describe ".attach_unix" do
    before do
      skip("Not supported on this platform") if Support.windows?
    end

    include_context "attached client" do
      let(:socket_path) { Support.socket_path }
      let(:stream) { "socket" }

      let!(:nvim_pid) do
        env = {"NVIM_LISTEN_ADDRESS" => socket_path}
        Process.spawn(env, *Support.child_argv, [:out, :err] => File::NULL)
      end

      let(:client) do
        begin
          Neovim.attach_unix(socket_path)
        rescue Errno::ENOENT, Errno::ECONNREFUSED
          retry
        end
      end

      after { Support.kill(nvim_pid) }
    end
  end

  describe ".attach_child" do
    include_context "attached client" do
      let(:stream) { "stdio" }

      let(:client) do
        Neovim.attach_child(Support.child_argv)
      end
    end

    after { client.shutdown }
  end

  describe ".executable" do
    it "returns the current executable" do
      expect(Neovim.executable).to be_a(Neovim::Executable)
    end
  end
end
