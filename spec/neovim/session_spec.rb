require "helper"

module Neovim
  RSpec.describe Session do
    include Support::Remote

    it "exposes a synchronous API" do
      with_neovim(:tcp) do |address|
        host, port = address.split(":")
        event_loop = EventLoop.tcp(host, port)
        stream = MsgpackStream.new(event_loop)
        async = AsyncSession.new(stream)
        session = Session.new(async)

        err, res = session.request(:vim_strwidth, "foobar")

        expect(err).to eq(nil)
        expect(res).to eq(6)
      end
    end
  end
end
