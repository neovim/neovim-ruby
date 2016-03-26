require "logger"
require "stringio"

module Neovim
  # Mixed into classes for unified logging helper methods.
  module Logging
    class << self
      attr_writer :logger
    end

    # Return the value of @logger, or construct it from the environment.
    # $NVIM_RUBY_LOG_FILE specifies a file to log to (default +STDOUT+), while
    # NVIM_RUBY_LOG_LEVEL specifies the level (default +WARN+)
    def self.logger
      return @logger if instance_variable_defined?(:@logger)

      if ENV["NVIM_RUBY_LOG_FILE"]
        @logger = Logger.new(ENV["NVIM_RUBY_LOG_FILE"])
      else
        @logger = Logger.new(STDERR)
      end

      if ENV["NVIM_RUBY_LOG_LEVEL"]
        @logger.level = Integer(ENV["NVIM_RUBY_LOG_LEVEL"])
      else
        @logger.level = Logger::WARN
      end

      @logger
    end

    private

    def fatal(msg)
      logger.fatal(self.class) { msg }
    end

    def warn(msg)
      logger.warn(self.class) { msg }
    end

    def info(msg)
      logger.info(self.class) { msg }
    end

    def debug(msg)
      logger.debug(self.class) { msg }
    end

    def logger
      Logging.logger
    end
  end
end
