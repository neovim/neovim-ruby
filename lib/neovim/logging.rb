require "logger"

module Neovim
  # Mixed into classes for unified logging helper methods.
  # @api private
  module Logging
    class << self
      attr_writer :logger
    end

    # Return the value of @logger, or construct it from the environment.
    # $NVIM_RUBY_LOG_FILE specifies a file to log to (default +STDOUT+), while
    # NVIM_RUBY_LOG_LEVEL specifies the level (default +WARN+)
    def self.logger(env=ENV)
      return @logger if instance_variable_defined?(:@logger)

      if env_file = env["NVIM_RUBY_LOG_FILE"]
        @logger = Logger.new(env_file)
      else
        @logger = Logger.new(STDERR)
      end

      if env_level = env["NVIM_RUBY_LOG_LEVEL"]
        begin
          @logger.level = Integer(env_level)
        rescue ArgumentError
          @logger.level = Logger.const_get(env_level.upcase)
        end
      else
        @logger.level = Logger::WARN
      end

      @logger
    end

    def self.included(base)
      base.send(:include, Helpers)
    end

    module Helpers
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
end
