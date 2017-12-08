require "helper"

module Neovim
  RSpec.describe Message do
    describe ".request" do
      it "builds a request" do
        request = Message.request(1, :method, [1, 2])

        expect(request).to be_a(Message::Request)
        expect(request.sync?).to eq(true)
        expect(request.id).to eq(1)
        expect(request.method_name).to eq(:method)
        expect(request.arguments).to eq([1, 2])
      end
    end

    describe ".response" do
      it "builds a response" do
        response = Message.response(1, "error", "value")

        expect(response).to be_a(Message::Response)
        expect(response.request_id).to eq(1)
        expect(response.error).to eq("error")
        expect(response.value).to eq("value")
      end
    end

    describe ".notification" do
      it "builds a notification" do
        notification = Message.notification(:method, [1, 2])

        expect(notification).to be_a(Message::Notification)
        expect(notification.sync?).to eq(false)
        expect(notification.method_name).to eq(:method)
        expect(notification.arguments).to eq([1, 2])
      end
    end

    describe ".from_array" do
      it "returns a request" do
        request = Message.from_array([0, 1, :method, [1, 2]])

        expect(request).to be_a(Message::Request)
        expect(request.id).to eq(1)
        expect(request.method_name).to eq(:method)
        expect(request.arguments).to eq([1, 2])
      end

      it "returns a response" do
        response = Message.from_array([1, 1, [1, "error"], "value"])

        expect(response).to be_a(Message::Response)
        expect(response.request_id).to eq(1)
        expect(response.error).to eq("error")
        expect(response.value).to eq("value")
      end

      it "returns a notification" do
        notification = Message.from_array([2, :method, [1, 2]])

        expect(notification).to be_a(Message::Notification)
        expect(notification.method_name).to eq(:method)
        expect(notification.arguments).to eq([1, 2])
      end
    end

    describe Message::Request do
      subject { described_class.new(1, :method, [1, 2]) }

      specify "#to_a" do
        expect(subject.to_a).to eq([0, 1, :method, [1, 2]])
      end

      describe "#received" do
        it "yields itself to the block" do
          request = Message::Request.new(1, :method, [1, 2])

          expect do |block|
            request.received({}, &block)
          end.to yield_with_args(request)
        end
      end
    end

    describe Message::Response do
      subject { described_class.new(2, "error", "result") }

      specify "#to_a" do
        expect(subject.to_a).to eq([1, 2, "error", "result"])
      end

      describe "#received" do
        it "yields itself to the response handler" do
          response = Message::Response.new(1, nil, "value")

          expect do |block|
            response.received(1 => block.to_proc)
          end.to yield_with_args(response)
        end
      end
    end

    describe Message::Notification do
      subject { described_class.new(:method, [1, 2]) }

      specify "#to_a" do
        expect(subject.to_a).to eq([2, :method, [1, 2]])
      end

      describe "#received" do
        it "yields itself to the block" do
          expect do |block|
            subject.received({}, &block)
          end.to yield_with_args(subject)
        end
      end
    end
  end
end
