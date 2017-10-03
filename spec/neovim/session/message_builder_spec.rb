require "helper"

module Neovim
  class Session
    RSpec.describe MessageBuilder do
      let(:message_builder) { MessageBuilder.new }

      describe "#write" do
        context "requests" do
          it "yields a valid request message" do
            expect do |y|
              message_builder.write(:request, :method, [1, 2], Proc.new {}, &y)
            end.to yield_with_args([0, 1, :method, [1, 2]])
          end

          it "increments the request id" do
            expect do |y|
              message_builder.write(:request, :method, [], Proc.new {}, &y)
              message_builder.write(:request, :method, [], Proc.new {}, &y)
            end.to yield_successive_args(
              [0, 1, :method, []],
              [0, 2, :method, []]
            )
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
            expect(request.method_name).to eq("method")
            expect(request.arguments).to eq([1, 2])
          end
        end

        context "responses" do
          it "calls the registered handler with a success response" do
            response = nil
            handler = Proc.new { |res| response = res }

            message_builder.write(:request, :method, [1, 2], handler) {}
            message_builder.read([1, 1, [nil, nil], :result])

            expect(response.request_id).to eq(1)
            expect(response.value).to eq(:result)
            expect(response.error).to eq(nil)
          end

          it "calls the registered handler with an error response" do
            response = nil

            handler = Proc.new do |res|
              response = res
            end

            message_builder.write(:request, :method, [1, 2], handler) {}
            message_builder.read([1, 1, [:some_err, "BOOM"], nil])

            expect(response.request_id).to eq(1)
            expect(response.error).to eq("BOOM")
            expect { response.value }.to raise_error("BOOM")
          end
        end

        context "notifications" do
          it "yields a notification object" do
            notification = nil
            message_builder.read([2, :method, [1, 2]]) do |ntf|
              notification = ntf
            end

            expect(notification.sync?).to eq(false)
            expect(notification.method_name).to eq("method")
            expect(notification.arguments).to eq([1, 2])
          end
        end
      end
    end
  end
end
