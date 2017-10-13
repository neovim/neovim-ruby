require "logger"
require "json"

module Neovim
  # Mixed into classes for unified logging helper methods.
  #
  # @api private
  module Logging
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
          {:_level => level, :_time => time.to_f}.merge!(fields)
        ) << "\n"
      end
    end
    private_class_method :json_formatter

    module Helpers
      private

      def log_exception(level, _method, ex)
        ex_fields = {:exception => ex.class, :message => ex.message}
        log(level, _method, ex_fields)
        log(:debug, _method, ex_fields.merge!(:backtrace => ex.backtrace))
      end

      def log(level, _method, fields)
        base = {:_class => self.class, :_method => _method}

        begin
          Logging.logger.public_send(level, base.merge!(fields.to_hash))
        rescue => ex
          Logging.logger.error("failed to log: #{ex}")
        end
      rescue
        # Inability to log shouldn't abort process
      end
    end
  end
end
