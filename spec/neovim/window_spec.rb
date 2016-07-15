require "helper"

module Neovim
  RSpec.describe Window do
    let(:client) { Neovim.attach_child(["nvim", "-n", "-u", "NONE"]) }
    let(:window) { client.current.window }
    after { client.shutdown }

    describe "if_ruby compatibility" do
      describe "#buffer" do
        it "returns the buffer displayed in the window" do
          expect(window.buffer).to be_a(Buffer)
        end
      end

      describe "#height" do
        it "returns the height of the window" do
          client.set_option("lines", 5)
          expect(window.height).to be(3)
        end
      end

      describe "#height=" do
        it "sets the height of the window" do
          expect {
            window.height = 5
          }.to change { window.height }.to(5)
        end
      end

      describe "#width" do
        it "returns the width of the window" do
          client.set_option("columns", 20)
          expect(window.width).to be(20)
        end
      end

      describe "#width=" do
        it "sets the width of a vertically split window" do
          client.command("vsplit")

          expect {
            window.width += 1
          }.to change { window.width }.by(1)
        end
      end

      describe "#cursor" do
        it "returns the cursor coordinates" do
          expect(window.cursor).to eq([1, 0])
        end
      end

      describe "#cursor=" do
        it "sets the cursor coodinates" do
          window.buffer.lines = ["one", "two"]

          expect {
            window.cursor = [2, 2]
          }.to change { window.cursor }.to([2, 2])
        end
      end
    end
  end
end
