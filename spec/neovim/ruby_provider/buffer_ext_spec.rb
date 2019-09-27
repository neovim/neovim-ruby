require "helper"
require "neovim/ruby_provider/buffer_ext"

module Neovim
  RSpec.describe Buffer do
    let!(:nvim) do
      Support.persistent_client.tap do |client|
        stub_const("::Vim", client)
      end
    end

    describe ".current" do
      it "returns the current buffer from the global Vim client" do
        expect(Buffer.current).to eq(nvim.get_current_buf)
      end
    end

    describe ".count" do
      it "returns the current buffer count from the global Vim client" do
        expect do
          nvim.command("new")
        end.to change { Buffer.count }.by(1)
      end
    end

    describe ".[]" do
      it "returns the buffer from the global Vim client at the given index" do
        buffer = Buffer[0]

        expect(buffer).to be_a(Buffer)
        expect(buffer).to eq(nvim.list_bufs[0])
      end
    end
  end
end
