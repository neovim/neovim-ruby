require "logger"
require "json"

module Neovim
  # Mixed into classes for unified logging helper methods.
  #
  # @api private
  module Logging
    TIMESTAMP_FORMAT = "%Y-%m-%dT%H:%M:%S.%6N".freeze

    # Return the value of @logger, or construct it from the environment.
    # $NVIM_RUBY_LOG_FILE specifies a file to log to (default +STDERR+), while
    # $NVIM_RUBY_LOG_LEVEL specifies the level (default +WARN+)
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

      @logger.formatter = json_formatter
      @logger
    end

    def self.logger=(logger)
      logger.formatter = json_formatter
      @logger = logger
    end

    def self.included(base)
      base.send(:include, Helpers)
    end

    def self.json_formatter
      Proc.new do |level, time, _, fields|
        JSON.generate(
          {
            :_level => level,
            :_time => time.strftime(TIMESTAMP_FORMAT)
          }.merge!(fields)
        ) << "\n"
      end
    end
    private_class_method :json_formatter

    module Helpers
      private

      def log(level, _method=nil, &block)
        begin
          Logging.logger.public_send(level) do
            {
              :_class => self.class,
              :_method => _method || block.binding.eval("__method__"),
            }.merge!(block.call)
          end
        rescue => ex
          Logging.logger.error("failed to log: #{ex.inspect}")
        end
      rescue
        # Inability to log shouldn't abort process
      end

      def log_exception(level, ex, _method)
        log(level, _method) do
          {:exception => ex.class, :message => ex.message}
        end

        log(:debug, _method) do
          {:exception => ex.class, :message => ex.message, :backtrace => ex.backtrace}
        end
      end
    end
  end
end
