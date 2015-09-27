require "helper"

module Neovim
  RSpec.describe Session do
    include Support::Remote

    it "sends synchronous requests" do
      with_neovim(:unix) do |socket_path|
        event_loop = EventLoop.unix(socket_path)
        stream = MsgpackStream.new(event_loop)
        async = AsyncSession.new(stream)
        session = Session.new(async)

        response = session.request(:vim_get_api_info)
        expect(response).to respond_to(:to_ary)
        expect(response.size).to eq(2)
      end
    end
  end
end
