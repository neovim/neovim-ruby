require "helper"
require "neovim/host/cli"

begin
  require "pty"
rescue LoadError
  # Not available on Windows
end

module Neovim
  class Host
    RSpec.describe CLI do
      let(:stdin) { StringIO.new }
      let(:stdout) { StringIO.new }
      let(:stderr) { StringIO.new }

      specify "-V" do
        expect do
          CLI.run("/exe/nv-rb-host", ["-V"], stdin, stdout, stderr)
        end.to raise_error(SystemExit) { |e| expect(e.status).to eq(0) }

        expect(stderr.string).to be_empty
        expect(stdout.string).to eq(Neovim::VERSION.to_s + "\n")
      end

      specify "-h" do
        expect do
          CLI.run("/exe/nv-rb-host", ["-h"], stdin, stdout, stderr)
        end.to raise_error(SystemExit) { |e| expect(e.status).to eq(0) }

        expect(stderr.string).to be_empty
        expect(stdout.string).to eq("Usage: nv-rb-host [-hV] rplugin_path ...\n")
      end

      it "fails with invalid arguments" do
        expect do
          CLI.run("/exe/nv-rb-host", ["-x"], stdin, stdout, stderr)
        end.to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }

        expect(stdout.string).to be_empty
        expect(stderr.string).to eq("invalid option: -x\n")
      end

      it "fails when run interactively" do
        if !defined?(PTY)
          skip "Skipping without `pty` library."
        end

        PTY.open do |tty,|
          expect do
            CLI.run("/exe/nv-rb-host", ["plugin.rb"], tty, stdout, stderr)
          end.to raise_error(SystemExit) { |e| expect(e.status).to eq(1) }

          expect(stdout.string).to be_empty
          expect(stderr.string).to eq("Can't run nv-rb-host interactively.\n")
        end
      end

      it "starts a stdio host" do
        nvim_r, host_w = IO.pipe
        host_r, nvim_w = IO.pipe

        nvim_u = MessagePack::Unpacker.new(nvim_r)
        nvim_p = MessagePack::Packer.new(nvim_w)

        Support.file_path("plugin").tap do |path|
          File.write(path, "Neovim.plugin { |p| p.function('Foo') }")

          thr = Thread.new do
            CLI.run("/exe/nv-rb-host", [path], host_r, host_w, stderr)
          end

          begin
            nvim_p.write([0, 1, :poll, []]).flush

            expect(nvim_u.read[0..1]).to eq([2, "nvim_set_client_info"])
            expect(nvim_u.read[0..2]).to eq([0, 2, "nvim_get_api_info"])

            nvim_p.write([1, 2, nil, [10, {"functions" => {}, "types" => {}}]]).flush
            expect(nvim_u.read).to eq([1, 1, nil, "ok"])

            nvim_p.write([0, 3, :specs, [path]]).flush
            *prefix, (payload, *) = nvim_u.read

            expect(prefix).to eq([1, 3, nil])
            expect(payload["name"]).to eq("Foo")
          ensure
            thr.kill.join
          end
        end
      end
    end
  end
end
