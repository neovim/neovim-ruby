require "logger"
require "stringio"

module Neovim
  module Logging
    def self.included(base)
      base.send(:attr_writer, :logger)
    end

    private

    def fatal(msg)
      logger.fatal(msg)
    end

    def warn(msg)
      logger.warn(msg)
    end

    def info(msg)
      logger.info(msg)
    end

    def debug(msg)
      logger.debug(msg)
    end

    def logger
      return @logger if instance_variable_defined?(:@logger)

      if ENV["NVIM_RUBY_LOG_FILE"].respond_to?(:to_str)
        @logger = Logger.new(ENV["NVIM_RUBY_LOG_FILE"].to_str)
      else
        @logger = Logger.new(StringIO.new)
      end

      if ENV["NVIM_RUBY_LOG_LEVEL"].respond_to?(:to_str)
        @logger.level = Integer(ENV["NVIM_RUBY_LOG_LEVEL"])
      else
        @logger.level = Logger::WARN
      end

      @logger.progname = self.class
      @logger
    end
  end
end
