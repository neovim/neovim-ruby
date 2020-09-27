require "logger"

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

      env_file, env_level =
        env.values_at("NVIM_RUBY_LOG_FILE", "NVIM_RUBY_LOG_LEVEL")

      @logger = Logger.new(env_file || STDERR)

      if /\S+/.match?(env_level)
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
      lambda do |level, time, _, fields|
        require "multi_json"

        MultiJson.encode(
          {
            _level: level,
            _time: time.strftime(TIMESTAMP_FORMAT)
          }.merge!(fields)
        ) << "\n"
      end
    end
    private_class_method :json_formatter

    # @api private
    module Helpers
      private

      def log(level, method=nil, &block)
        begin
          Logging.logger.public_send(level) do
            {
              _class: self.class,
              _method: method || block.binding.eval("__method__")
            }.merge!(yield)
          end
        rescue => ex
          Logging.logger.error("failed to log: #{ex.inspect}")
        end
      rescue
        # Inability to log shouldn't abort process
      end

      def log_exception(level, ex, method)
        log(level, method) do
          {exception: ex.class, message: ex.message}
        end

        log(:debug, method) do
          {exception: ex.class, message: ex.message, backtrace: ex.backtrace}
        end
      end
    end
  end
end
