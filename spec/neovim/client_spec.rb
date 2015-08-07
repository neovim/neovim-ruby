# coding: utf-8
require "helper"

module Neovim
  RSpec.describe Client, :remote do
    describe "#respond_to?" do
      it "returns true for all rpc functions" do
        @client.api_info.fetch(1).fetch("functions").each do |funcdef|
          name = funcdef.fetch("name")
          next unless name =~ /^vim_/
          expect(@client).to respond_to(name.sub(/^vim_/, ""))
        end
      end

      it "returns true for non-rpc functions" do
        expect(@client).to respond_to(:inspect)
      end

      it "returns false otherwise" do
        expect(@client).not_to respond_to(:foobar)
      end
    end

    describe "void return functions" do
      it "returns self" do
        expect(@client.command("echom 'hi'")).to be(@client)
      end
    end

    describe "String return functions" do
      it "returns a string" do
        expect(@client.get_current_line).to respond_to(:to_str)
      end
    end

    describe "Integer return functions" do
      it "returns an integer" do
        expect(@client.strwidth("str")).to respond_to(:to_int)
      end
    end

    describe "Object return functions" do
      it "returns an object" do
        @client.command("let g:v1 = \"a\"").command("let g:v2 = [1, 2]")
        expect(@client.eval("g:")).to eq("v1" => "a", "v2" => [1, 2])
      end
    end

    describe "ArrayOf return functions" do
      it "returns an array" do
        expect(@client.list_runtime_paths).to respond_to(:to_ary)
      end
    end

    describe "Buffer return functions" do
      it "returns a buffer" do
        expect(@client.get_current_buffer).to be_a(Buffer)
      end
    end

    describe "Window return functions" do
      it "returns a window" do
        expect(@client.get_current_window).to be_a(Window)
      end
    end

    describe "Tabpage return functions" do
      it "returns a tabpage" do
        expect(@client.get_current_tabpage).to be_a(Tabpage)
      end
    end
  end
end
