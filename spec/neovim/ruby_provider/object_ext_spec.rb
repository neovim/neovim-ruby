require "helper"
require "neovim/ruby_provider/object_ext"

RSpec.describe Object do
  describe "#to_msgpack" do
    it "converts classes to strings" do
      expect(MessagePack.pack(String)).to eq(MessagePack.pack("String"))
    end
  end
end
