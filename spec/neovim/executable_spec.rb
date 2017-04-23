require "helper"

module Neovim
  RSpec.describe Executable do
    let(:executable) { Executable.new(ENV) }

    describe "#path" do
      it "returns the value of env['NVIM_EXECUTABLE']" do
        executable = Executable.new("NVIM_EXECUTABLE" => "/foo/nvim")
        expect(executable.path).to eq("/foo/nvim")
      end

      it "defaults to 'nvim'" do
        executable = Executable.new({})
        expect(executable.path).to eq("nvim")
      end
    end

    describe "#version" do
      it "returns the current nvim version" do
        expect(executable.version.size).to be > 0
      end

      it "raises with an invalid executable path" do
        executable = Executable.new("NVIM_EXECUTABLE" => "/dev/null")

        expect {
          executable.version
        }.to raise_error(Executable::Error, /\/dev\/null/)
      end
    end
  end
end
