require "helper"

module Neovim
  RSpec.describe Executable do
    describe ".from_env" do
      it "respects NVIM_EXECUTABLE" do
        executable = Executable.from_env("NVIM_EXECUTABLE" => "/foo/nvim")
        expect(executable.path).to eq("/foo/nvim")
      end

      it "returns a default path" do
        executable = Executable.from_env({})
        expect(executable.path).to eq("nvim")
      end
    end

    describe "#version" do
      it "returns the current nvim version" do
        executable = Executable.from_env
        expect(executable.version).to match(/^\d+\.\d+\.\d+/)
      end

      it "raises with an invalid executable path" do
        executable = Executable.new(File::NULL)

        expect do
          executable.version
        end.to raise_error(Executable::Error, Regexp.new(File::NULL))
      end
    end
  end
end
