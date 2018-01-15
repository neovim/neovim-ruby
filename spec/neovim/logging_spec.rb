require "helper"
require "multi_json"

module Neovim
  RSpec.describe Logging do
    around do |spec|
      old_logger = Logging.logger

      begin
        Logging.send(:remove_instance_variable, :@logger)
        spec.run
      ensure
        Logging.logger = old_logger
      end
    end

    describe ".logger" do
      it "fetches the output from $NVIM_RUBY_LOG_FILE" do
        logger = instance_double(Logger, :level= => nil, :formatter= => nil)
        expect(Logger).to receive(:new).with("/tmp/nvim.log").and_return(logger)
        Logging.logger("NVIM_RUBY_LOG_FILE" => "/tmp/nvim.log")
        expect(Logging.logger).to be(logger)
      end

      it "defaults the output to STDERR" do
        logger = instance_double(Logger, :level= => nil, :formatter= => nil)
        expect(Logger).to receive(:new).with(STDERR).and_return(logger)
        Logging.logger({})
        expect(Logging.logger).to be(logger)
      end

      it "fetches the level from $NVIM_RUBY_LOG_LEVEL as a string" do
        logger = instance_double(Logger, :formatter= => nil)
        expect(Logger).to receive(:new).and_return(logger)
        expect(logger).to receive(:level=).with(Logger::DEBUG)
        Logging.logger("NVIM_RUBY_LOG_LEVEL" => "DEBUG")
        expect(Logging.logger).to be(logger)
      end

      it "fetches the level from $NVIM_RUBY_LOG_LEVEL as an integer" do
        logger = instance_double(Logger, :formatter= => nil)
        expect(Logger).to receive(:new).and_return(logger)
        expect(logger).to receive(:level=).with(0)
        Logging.logger("NVIM_RUBY_LOG_LEVEL" => "0")
        expect(Logging.logger).to be(logger)
      end

      it "defaults the level to WARN" do
        logger = instance_double(Logger, :formatter= => nil)
        expect(Logger).to receive(:new).and_return(logger)
        expect(logger).to receive(:level=).with(Logger::WARN)
        Logging.logger({})
        expect(Logging.logger).to be(logger)
      end
    end

    describe Logging::Helpers do
      let!(:log) do
        StringIO.new.tap do |io|
          logger = Logger.new(io)
          logger.level = Logger::DEBUG
          Neovim.logger = logger
        end
      end

      let(:klass) do
        Class.new do
          include Logging

          def public_log(level, fields)
            log(level) { fields }
          end

          def public_log_exception(*args)
            log_exception(*args)
          end
        end
      end

      let(:obj) { klass.new }

      describe "#log" do
        it "logs JSON at the specified level" do
          obj.public_log(:info, foo: "bar")
          logged = MultiJson.decode(log.string)

          expect(logged).to match(
            "_level" => "INFO",
            "_class" => klass.to_s,
            "_method" => "public_log",
            "_time" => /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+/,
            "foo" => "bar"
          )
        end
      end

      describe "#log_exception" do
        it "logs JSON at the specified level and debugs the backtrace" do
          ex = RuntimeError.new("BOOM")
          ex.set_backtrace(["one", "two"])
          obj.public_log_exception(:fatal, ex, :some_method)
          lines = log.string.lines.to_a

          fatal = MultiJson.decode(lines[0])
          debug = MultiJson.decode(lines[1])

          expect(fatal).to match(
            "_level" => "FATAL",
            "_class" => klass.to_s,
            "_method" => "some_method",
            "_time" => /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+/,
            "exception" => "RuntimeError",
            "message" => "BOOM"
          )

          expect(debug).to match(
            "_level" => "DEBUG",
            "_class" => klass.to_s,
            "_method" => "some_method",
            "_time" => /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+/,
            "exception" => "RuntimeError",
            "message" => "BOOM",
            "backtrace" => ["one", "two"]
          )
        end
      end
    end
  end
end
