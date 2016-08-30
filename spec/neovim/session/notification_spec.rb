require "helper"

module Neovim
  class Session
    RSpec.describe Notification do
      let(:notification) { Notification.new(:method, ["arg"]) }

      it "has readers" do
        expect(notification.method_name).to eq("method")
        expect(notification.arguments).to eq(["arg"])
      end

      describe "#sync?" do
        it "is false" do
          expect(notification.sync?).to be(false)
        end
      end
    end
  end
end
