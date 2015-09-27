require "helper"

module Neovim
  RSpec.describe EventLoop do
    context "TCP" do
      it "writes data" do
        pending "START HERE: spin up a nc server and assert this thing writes to it"
        event_loop = EventLoop.tcp("0.0.0.0", 3333)
        messages = []

        thr = Thread.new do
          event_loop.run do |msg|
            messages << msg
            event_loop.stop
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
        event_loop = EventLoop.unix("/tmp/#{$$}.sock")
        messages = []

        thr = Thread.new do
          event_loop.run do |msg|
            messages << msg
            event_loop.stop
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
