require "helper"

module Neovim
  RSpec.describe RPC do
    include Support::Remote

    around do |spec|
      with_neovim_connection(:embed) do |conn|
        @rpc = RPC.new(conn)
        spec.run
      end
    end

    describe "#defined?" do
      it "returns true for implemented functions" do
        expect(@rpc.defined?(:vim_get_current_buffer)).to be(true)
      end

      it "returns false otherwise" do
        expect(@rpc.defined?(:foobar)).to be(false)
      end
    end

    describe "#send" do
      describe "void return functions" do
        it "returns nil" do
          expect(@rpc.send(:vim_command, "echom 'hi'")).to be(nil)
        end
      end

      describe "String return functions" do
        it "returns a string" do
          expect(@rpc.send(:vim_get_current_line)).to respond_to(:to_str)
        end
      end

      describe "Integer return functions" do
        it "returns an integer" do
          expect(@rpc.send(:vim_strwidth, "str")).to respond_to(:to_int)
        end
      end

      describe "Object return functions" do
        it "returns an object" do
          @rpc.send(:vim_command, "let g:v1 = \"a\"")
          @rpc.send(:vim_command, "let g:v2 = [1, 2]")
          expect(@rpc.send(:vim_eval, "g:")).to eq("v1" => "a", "v2" => [1, 2])
        end
      end

      describe "ArrayOf return functions" do
        it "returns an array" do
          expect(@rpc.send(:vim_list_runtime_paths)).to respond_to(:to_ary)
        end
      end

      describe "Buffer return functions" do
        it "returns a buffer" do
          expect(@rpc.send(:vim_get_current_buffer)).to be_a(Buffer)
        end
      end

      describe "Window return functions" do
        it "returns a window" do
          expect(@rpc.send(:vim_get_current_window)).to be_a(Window)
        end
      end

      describe "Tabpage return functions" do
        it "returns a tabpage" do
          expect(@rpc.send(:vim_get_current_tabpage)).to be_a(Tabpage)
        end
      end
    end
  end
end
