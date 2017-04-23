module Neovim
  class Executable
    VERSION_PATTERN = /\ANVIM v?(.+)$/

    class Error < RuntimeError; end

    def initialize(environment)
      @environment = environment
    end

    def path
      @path ||= @environment.fetch("NVIM_EXECUTABLE", "nvim")
    end

    def version
      @version ||= IO.popen([path, "--version"]) do |io|
        io.gets[VERSION_PATTERN, 1]
      end
    rescue => e
      raise Error, "Couldn't load #{path}: #{e}"
    end

    def path=(path)
      @version = nil
      @path = path
    end
  end
end
