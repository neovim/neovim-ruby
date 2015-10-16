require "helper"

module Neovim
  RSpec.describe Session do
    let(:session) do
      event_loop = EventLoop.child(["-n", "-u", "NONE"])
      stream = MsgpackStream.new(event_loop)
      async = AsyncSession.new(stream)
      Session.new(async)
    end

    it "exposes a synchronous API" do
      expect(session.request(:vim_strwidth, "foobar")).to eq(6)
    end

    it "raises an exception when there are errors" do
      expect {
        session.request(:vim_strwidth, "too", "many")
      }.to raise_error("Wrong number of arguments: expecting 1 but got 2")
    end

    describe "#api_methods_for_prefix" do
      it "returns relevant functions without a prefix" do
        methods = session.api_methods_for_prefix("vim_")
        expect(methods).to include(:strwidth)
      end
    end
  end
end
