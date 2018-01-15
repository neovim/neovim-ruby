module Neovim
  # Object representing the `nvim` executable.
  class Executable
    VERSION_PATTERN = /\ANVIM v?(.+)$/

    class Error < RuntimeError; end

    # Load the current executable from the +NVIM_EXECUTABLE+ environment
    # variable.
    #
    # @param env [Hash]
    # @return [Executable]
    def self.from_env(env=ENV)
      new(env.fetch("NVIM_EXECUTABLE", "nvim"))
    end

    attr_reader :path

    def initialize(path)
      @path = path
    end

    # Fetch the +nvim+ version.
    #
    # @return [String]
    def version
      @version ||= IO.popen([@path, "--version"]) do |io|
        io.gets[VERSION_PATTERN, 1]
      end
    rescue => e
      raise Error, "Couldn't load #{@path}: #{e}"
    end
  end
end
