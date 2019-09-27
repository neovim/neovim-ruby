require "helper"

module Neovim
  RSpec.describe Window do
    let(:client) { Support.persistent_client }
    let(:window) { client.current.window }

    before do
      client.command("normal ione")
      client.command("normal otwo")
      client.command("normal gg")
      client.command("vsplit")
    end

    describe "#buffer" do
      it "returns the window's buffer" do
        expect(window.buffer).to eq(client.get_current_buf)
      end
    end

    describe "#height", "#height=" do
      it "adjusts the window height" do
        expect do
          window.height -= 1
        end.to change { window.height }.by(-1)
      end
    end

    describe "#width", "#width=" do
      it "adjusts the window width" do
        expect do
          window.width -= 1
        end.to change { window.width }.by(-1)
      end
    end

    describe "#cursor", "#cursor=" do
      it "adjusts the window cursor" do
        expect do
          window.cursor = [2, 0]
        end.to change { window.cursor }.to([2, 0])
      end
    end
  end
end
