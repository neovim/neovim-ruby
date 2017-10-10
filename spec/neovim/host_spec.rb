require "helper"
require "neovim/host"

module Neovim
  RSpec.describe Host do
    describe ".run" do
      let!(:push_pipe) { IO.pipe }
      let!(:pull_pipe) { IO.pipe }

      let(:host_rd) { push_pipe[0] }
      let(:host_wr) { pull_pipe[1] }
      let(:nvim_rd) { pull_pipe[0] }
      let(:nvim_wr) { push_pipe[1] }

      let(:plugin_path) do
        Support.file_path("my_plugin").tap do |path|
          File.write(path, <<-PLUGIN)
            Neovim.plugin do |plug|
              plug.command(:StrWidth, :nargs => 1, :sync => true) do |client, arg|
                arg.bytesize
              end

              plug.command(:Boom, :sync => true) do |client|
                raise "BOOM"
              end
            end
          PLUGIN
        end
      end

      let!(:host_pid) do
        fork do
          $stdout.reopen(host_wr)
          $stdin.reopen(host_rd)

          Host.run([plugin_path])
        end
      end

      before do
        _, reqid, method = MessagePack.unpack(nvim_rd.readpartial(1024))
        expect(method).to eq("nvim_get_api_info")

        session = Session.new(EventLoop.child(Support.child_argv))
        api_info = session.request(:nvim_get_api_info)
        session.shutdown

        nvim_wr.write(MessagePack.pack([1, reqid, nil, api_info]))
        nvim_wr.flush
      end

      after do
        begin
          Process.kill(:TERM, host_pid)
          Process.waitpid(host_pid)
        rescue Errno::ESRCH, Errno::ECHILD
        end
      end

      it "responds 'ok' to the 'poll' request" do
        message = MessagePack.pack([0, 0, :poll, []])
        nvim_wr.write(message)
        nvim_wr.flush

        response = MessagePack.unpack(nvim_rd.readpartial(1024))
        expect(response).to eq([1, 0, nil, "ok"])
      end

      it "responds with specs to the 'specs' request" do
        message = MessagePack.pack([0, 0, :specs, [plugin_path]])
        nvim_wr.write(message)
        nvim_wr.flush

        response = MessagePack.unpack(nvim_rd.readpartial(1024))
        expect(response).to eq(
          [
            1,
            0,
            nil,
            [
              {
                "type" => "command",
                "name" => "StrWidth",
                "sync" => true,
                "opts" => {"nargs" => 1},
              },
              {
                "type" => "command",
                "name" => "Boom",
                "sync" => true,
                "opts" => {},
              },
            ],
          ],
        )
      end

      it "delegates to plugin handlers" do
        message = MessagePack.pack([0, 0, "#{plugin_path}:command:StrWidth", ["hi"]])
        nvim_wr.write(message)
        nvim_wr.flush

        response = MessagePack.unpack(nvim_rd.readpartial(1024))
        expect(response).to eq([1, 0, nil, 2])
      end

      it "handles exceptions in plugin handlers" do
        message = MessagePack.pack([0, 0, "#{plugin_path}:command:Boom", ["hi"]])
        nvim_wr.write(message)
        nvim_wr.flush

        response = MessagePack.unpack(nvim_rd.readpartial(1024))
        expect(response).to eq([1, 0, "BOOM", nil])
      end

      it "handles unknown requests" do
        message = MessagePack.pack([0, 0, "foobar", []])
        nvim_wr.write(message)
        nvim_wr.flush

        response = MessagePack.unpack(nvim_rd.readpartial(1024))
        expect(response).to eq([1, 0, "Unknown request foobar", nil])
      end
    end
  end
end
