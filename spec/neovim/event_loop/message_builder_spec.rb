require "helper"

module Neovim
  class EventLoop
    RSpec.describe MessageBuilder do
      let(:message_builder) { MessageBuilder.new }

      describe "#write" do
        context "requests" do
          it "yields a valid request message" do
            expect do |y|
              message_builder.write(:request, 1, :method, [1, 2], Proc.new {}, &y)
            end.to yield_with_args([0, 1, :method, [1, 2]])
          end
        end

        context "responses" do
          it "yields a valid response message" do
            expect do |y|
              message_builder.write(:response, 2, :value, "error msg", &y)
            end.to yield_with_args([1, 2, "error msg", :value])
          end
        end

        context "notifications" do
          it "yields a valid notification message" do
            expect do |y|
              message_builder.write(:notification, :method, [1, 2], &y)
            end.to yield_with_args([2, :method, [1, 2]])
          end
        end
      end

      describe "#read" do
        context "requests" do
          it "yields a request object" do
            request = nil
            message_builder.read([0, 1, :method, [1, 2]]) do |req|
              request = req
            end

            expect(request.sync?).to eq(true)
            expect(request.id).to eq(1)
            expect(request.method_name).to eq(:method)
            expect(request.arguments).to eq([1, 2])
          end

          describe "#received" do
            it "yields the request object" do
              expect do |block|
                message_builder.read([0, 1, :method, [1, 2]]) do |req|
                  req.received({}, &block)
                end
              end.to yield_with_args(kind_of(MessageBuilder::Request))
            end
          end
        end

        context "responses" do
          it "yields a response object" do
            response = nil
            message_builder.read([1, 2, [1, "error msg"], :return_value]) do |res|
              response = res
            end

            expect(response.request_id).to eq(2)
            expect(response.error).to eq("error msg")
            expect(response.value).to eq(:return_value)
          end

          describe "#received" do
            it "calls the response handler with the notification" do
              expect do |block|
                message_builder.read([1, 2, nil, :return_value]) do |res|
                  res.received(2 => block.to_proc)
                end
              end.to yield_with_args(kind_of(MessageBuilder::Response))
            end
          end
        end

        context "notifications" do
          it "yields a notification object" do
            notification = nil
            message_builder.read([2, :method, [1, 2]]) do |ntf|
              notification = ntf
            end

            expect(notification.sync?).to eq(false)
            expect(notification.method_name).to eq(:method)
            expect(notification.arguments).to eq([1, 2])
          end

          describe "#received" do
            it "yields the notification object" do
              expect do |block|
                message_builder.read([2, :method, [1, 2]]) do |ntf|
                  ntf.received({}, &block)
                end
              end.to yield_with_args(kind_of(MessageBuilder::Notification))
            end
          end
        end
      end
    end
  end
end
