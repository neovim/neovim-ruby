require "helper"
require "neovim/host"

module Neovim
  RSpec.describe Host do
    describe ".run" do
      let!(:push_pipe) { IO.pipe }
      let!(:pull_pipe) { IO.pipe }

      let(:host_rd) { push_pipe[0] }
      let(:host_wr) { pull_pipe[1] }
      let(:nvim_rd) { MessagePack::Unpacker.new(pull_pipe[0]) }
      let(:nvim_wr) { MessagePack::Packer.new(push_pipe[1]) }

      let(:plugin_path) do
        Support.file_path("my_plugin").tap do |path|
          File.write(path, <<-PLUGIN)
            Neovim.plugin do |plug|
              plug.command(:Echo, nargs: 1, sync: true) do |client, arg|
                arg
              end

              plug.command(:Boom, sync: true) do |client|
                raise "BOOM"
              end

              plug.command(:BoomAsync) do |client|
                raise "BOOM ASYNC"
              end
            end
          PLUGIN
        end
      end

      let!(:host_thread) do
        connection = Connection.new(host_rd, host_wr)
        event_loop = EventLoop.new(connection)

        Thread.new do
          Host.run([plugin_path], event_loop)
        end
      end

      after { host_thread.kill.join }

      context "poll" do
        it "initializes a client, sets client info, and responds 'ok'" do
          nvim_wr.write([0, 1, :poll, []]).flush

          expect(nvim_rd.read).to match([2, "nvim_set_client_info", duck_type(:to_ary)])

          type, reqid, method = nvim_rd.read
          expect([type, reqid, method]).to match([0, duck_type(:to_int), "nvim_get_api_info"])

          api_info = [0, {"types" => {}, "functions" => {}}]
          nvim_wr.write([1, reqid, nil, api_info]).flush

          expect(nvim_rd.read).to eq([1, 1, nil, "ok"])
        end
      end

      context "after poll" do
        before do
          nvim_wr.write([0, 1, :poll, []]).flush

          expect(nvim_rd.read[1]).to eq("nvim_set_client_info")

          _, reqid, method = nvim_rd.read

          expect(method).to eq("nvim_get_api_info")

          api_info = Support.persistent_client.get_api_info

          nvim_wr.write([1, reqid, nil, api_info]).flush

          expect(nvim_rd.read[3]).to eq("ok")
        end

        it "responds with specs to the 'specs' request" do
          nvim_wr.write([0, 2, :specs, [plugin_path]]).flush

          expect(nvim_rd.read).to eq(
            [
              1,
              2,
              nil,
              [
                {
                  "type" => "command",
                  "name" => "Echo",
                  "sync" => true,
                  "opts" => {"nargs" => 1}
                },
                {
                  "type" => "command",
                  "name" => "Boom",
                  "sync" => true,
                  "opts" => {}
                },
                {
                  "type" => "command",
                  "name" => "BoomAsync",
                  "sync" => false,
                  "opts" => {}
                }
              ]
            ]
          )
        end

        it "delegates to plugin handlers" do
          nvim_wr.write([0, 0, "#{plugin_path}:command:Echo", ["hi"]]).flush
          expect(nvim_rd.read).to eq([1, 0, nil, "hi"])
        end

        it "handles exceptions in sync plugin handlers" do
          nvim_wr.write([0, 0, "#{plugin_path}:command:Boom", ["hi"]]).flush
          expect(nvim_rd.read).to eq([1, 0, "BOOM", nil])
        end

        it "handles exceptions in async plugin handlers" do
          nvim_wr.write([2, "#{plugin_path}:command:BoomAsync", ["hi"]]).flush

          expect(nvim_rd.read).to match_array(
            [
              0, duck_type(:to_int), "nvim_err_writeln",
              [/my_plugin:command:BoomAsync: \(RuntimeError\) BOOM ASYNC/]
            ]
          )
        end

        it "handles unknown requests" do
          nvim_wr.write([0, 0, "foobar", []]).flush
          expect(nvim_rd.read).to eq([1, 0, "Unknown request foobar", nil])
        end
      end
    end
  end
end
