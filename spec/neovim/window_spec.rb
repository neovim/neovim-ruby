require "helper"

module Neovim
  RSpec.describe Window do
    let(:client) { Neovim.attach_child(["--headless", "-n", "-u", "NONE"]) }
    let(:window) { client.current.window }

    before do
      client.command("normal 3Oabc")
      client.command("normal gg")
    end

    describe "#cursor" do
      it "moves line-wise" do
        expect {
          window.cursor.line += 1
        }.to change { window.cursor.coordinates }.from([1, 0]).to([2, 0])

        expect {
          window.cursor.line -= 1
        }.to change { window.cursor.coordinates }.from([2, 0]).to([1, 0])
      end

      it "moves column-wise" do
        expect {
          window.cursor.column += 1
        }.to change { window.cursor.coordinates }.from([1, 0]).to([1, 1])

        expect {
          window.cursor.column -= 1
        }.to change { window.cursor.coordinates }.from([1, 1]).to([1, 0])
      end

      it "moves to an absolute position" do
        expect {
          window.cursor.coordinates = [1, 1]
        }.to change { window.cursor.coordinates }.to([1, 1])
      end
    end
  end
end
