require "msgpack"
require "securerandom"
require "helper"
require "neovim/event_loop/serializer"

module Neovim
  class EventLoop
    RSpec.describe Serializer do
      let(:serializer) { Serializer.new }

      describe "write" do
        it "yields msgpack" do
          expect do |y|
            serializer.write([1, :foo], &y)
          end.to yield_with_args(MessagePack.pack([1, :foo]))
        end
      end

      describe "read" do
        it "yields an unpacked object" do
          expect do |y|
            serializer.read(MessagePack.pack([1, :foo]), &y)
          end.to yield_with_args([1, "foo"])
        end

        it "accumulates chunks of data and yields a single object" do
          object = Array.new(16) { SecureRandom.hex(4) }
          msgpack = MessagePack.pack(object)

          expect do |y|
            msgpack.chars.each_slice(10) do |chunk|
              serializer.read(chunk.join, &y)
            end
          end.to yield_with_args(object)
        end
      end

      describe "#register_type" do
        it "registers a msgpack ext type" do
          ext_class = Struct.new(:id) do
            def self.from_msgpack_ext(data)
              new(data.unpack('N')[0])
            end

            def to_msgpack_ext
              [self.id].pack('C')
            end
          end

          serializer.register_type(42) do |id|
            ext_class.new(id)
          end

          factory = MessagePack::Factory.new
          factory.register_type(42, ext_class)
          obj = ext_class.new(1)
          msgpack = factory.packer.write(obj).flush.to_str

          expect do |y|
            serializer.read(msgpack, &y)
          end.to yield_with_args(obj)
        end
      end
    end
  end
end
