require "helper"

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
        logger = instance_double(Logger, :level= => nil)
        expect(Logger).to receive(:new).with("/tmp/nvim.log").and_return(logger)
        Logging.logger("NVIM_RUBY_LOG_FILE" => "/tmp/nvim.log")
        expect(Logging.logger).to be(logger)
      end

      it "defaults the output to STDERR" do
        logger = instance_double(Logger, :level= => nil)
        expect(Logger).to receive(:new).with(STDERR).and_return(logger)
        Logging.logger({})
        expect(Logging.logger).to be(logger)
      end

      it "fetches the level from $NVIM_RUBY_LOG_LEVEL as a string" do
        logger = instance_double(Logger)
        expect(Logger).to receive(:new).and_return(logger)
        expect(logger).to receive(:level=).with(Logger::DEBUG)
        Logging.logger("NVIM_RUBY_LOG_LEVEL" => "DEBUG")
        expect(Logging.logger).to be(logger)
      end

      it "fetches the level from $NVIM_RUBY_LOG_LEVEL as an integer" do
        logger = instance_double(Logger)
        expect(Logger).to receive(:new).and_return(logger)
        expect(logger).to receive(:level=).with(0)
        Logging.logger("NVIM_RUBY_LOG_LEVEL" => "0")
        expect(Logging.logger).to be(logger)
      end

      it "defaults the level to WARN" do
        logger = instance_double(Logger)
        expect(Logger).to receive(:new).and_return(logger)
        expect(logger).to receive(:level=).with(Logger::WARN)
        Logging.logger({})
        expect(Logging.logger).to be(logger)
      end
    end
  end
end
