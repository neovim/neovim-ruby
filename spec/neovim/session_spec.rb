require "helper"

module Neovim
  RSpec.describe Session do
    it "exposes a synchronous API" do
      event_loop = EventLoop.child(["-n", "-u", "NONE"])
      stream = MsgpackStream.new(event_loop)
      async = AsyncSession.new(stream)
      session = Session.new(async)

      expect(session.request(:vim_strwidth, "foobar")).to eq(6)
    end

    it "raises an exception when there are errors" do
      event_loop = EventLoop.child(["-n", "-u", "NONE"])
      stream = MsgpackStream.new(event_loop)
      async = AsyncSession.new(stream)
      session = Session.new(async)

      expect {
        session.request(:vim_strwidth, "too", "many")
      }.to raise_error("Wrong number of arguments: expecting 1 but got 2")
    end
  end
end
