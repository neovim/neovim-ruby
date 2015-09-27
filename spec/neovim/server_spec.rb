require "helper"

module Neovim
  RSpec.describe Server do
    context "TCP" do
      it "writes data" do
        pending "START HERE: spin up a nc server and assert this thing writes to it"
        server = Server.tcp("0.0.0.0", 3333)
        messages = []

        thr = Thread.new do
          server.run do |msg|
            messages << msg
            server.stop
          end
        end

        IO.popen(["/usr/bin/nc", "0.0.0.0", "3333"], "r+") do |io|
          io.write("data")
          io.close_write
        end

        thr.join
        expect(messages).to eq(["data"])
      end
    end

    context "Unix" do
      it "writes data" do
        pending "START HERE: spin up a nc server and assert this thing writes to it"
        server = Server.unix("/tmp/#{$$}.sock")
        messages = []

        thr = Thread.new do
          server.run do |msg|
            messages << msg
            server.stop
          end
        end

        IO.popen(["/usr/bin/nc", "-U", "/tmp/#{$$}.sock"], "r+") do |io|
          io.write("data")
          io.close_write
        end

        thr.join
        expect(messages).to eq(["data"])
      end
    end
  end
end
