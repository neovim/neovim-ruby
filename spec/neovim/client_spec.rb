# coding: utf-8
require "helper"

module Neovim
  RSpec.describe Client, :remote => true do
    describe "#message" do
      it "prints a message to neovim" do
        skip "Still deciding how to test this (also it doesn't work)"
        @client.message("This is a message")
      end
    end

    describe "#error" do
      it "prints an error message to neovim" do
        skip "Still deciding how to test this (also it doesn't work)"
        @client.error("This is an error message")
      end
    end

    describe "#command" do
      it "runs the provided command" do
        expect {
          @client.command("set hlsearch")
        }.to change { @client.option("hlsearch").value }.from(false).to(true)
      end
    end

    describe "#evaluate" do
      it "evaluates the provided vim expression" do
        @client.command("let g:v1 = \"a\"")
        @client.command("let g:v2 = [1, 2]")

        expect(@client.evaluate("g:")).to eq("v1" => "a", "v2" => [1, 2])
      end
    end

    describe "#push_keys" do
      it "pushes keys" do
        skip "This just blows up, punting for now."
      end
    end

    describe "#strwidth" do
      it "returns the string cell width" do
        expect(@client.strwidth("テスト")).to eq(6)
      end
    end

    describe "#runtime_paths" do
      it "returns an array of runtime paths" do
        expect(@client.runtime_paths).to respond_to(:to_ary)
      end
    end

    describe "#change_directory" do
      it "changes the neovim working directory" do
        skip "Still deciding how to test this"
        @client.change_directory("..")
      end

      it "raises an exception on failure" do
        expect {
          @client.change_directory("/this/directory/doesnt/exist")
        }.to raise_error(Neovim::RPC::Error, /failed.+change directory/i)
      end
    end

    describe "#buffers" do
      it "returns all buffers" do
        buffers = @client.buffers
        expect(buffers.size).to eq(1)
        expect(buffers.first).to be_a(Buffer)
      end
    end

    describe "#current_buffer" do
      it "returns a buffer" do
        buffer = @client.current_buffer
        expect(buffer).to be_a(Buffer)
      end
    end

    describe "#current_line" do
      it "returns an empty string if the current line is empty" do
        expect(@client.current_line).to eq("")
      end

      it "returns the contents of the line" do
        @client.current_line = "New content"
        expect(@client.current_line).to eq("New content")
      end
    end

    describe "#current_line=" do
      it "sets the content of the current line" do
        @client.current_line = "New content"
        expect(@client.current_line).to eq("New content")
      end

      it "returns the new content" do
        expect(@client.current_line = "New content").to eq("New content")
      end

      it "empties the line" do
        @client.current_line = "New content"
        @client.current_line = ""
        expect(@client.current_line).to eq("")
      end
    end

    describe "#windows" do
      it "returns a list of windows" do
        windows = @client.windows
        expect(windows.size).to eq(1)
        expect(windows.first).to be_a(Window)
      end
    end

    describe "#current_window" do
      it "returns the current window" do
        expect(@client.current_window).to be_a(Window)
      end
    end

    describe "#current_window=" do
      it "sets the current window" do
        @client.command("vsp")
        expect(@client.current_window.index).not_to eq(1)
        expect {
          @client.current_window = 1
        }.to change { @client.current_window.index }.to(1)
      end

      it "raises an exception for an invalid window index" do
        expect {
          @client.current_window = 999
        }.to raise_error(/invalid window id/i)
      end
    end

    describe "#tabpages" do
      it "returns tabpages" do
        expect {
          @client.command("tabnew")
        }.to change { @client.tabpages.count }.from(1).to(2)

        expect {
          @client.command("tabclose")
        }.to change { @client.tabpages.count }.from(2).to(1)
      end
    end

    describe "#current_tabpage" do
      it "returns the current tabpage" do
        tabpage = @client.current_tabpage
        expect(tabpage).to be_a(Tabpage)
        expect(tabpage).to eq(@client.tabpages.first)
      end
    end

    describe "#current_tabpage=" do
      it "sets the current tabpage" do
        initial_index = @client.current_tabpage.index
        @client.command("tabnew")
        expect(@client.current_tabpage.index).to be > initial_index

        @client.current_tabpage = initial_index
        expect(@client.current_tabpage.index).to eq(initial_index)
      end
    end

    describe "#variable" do
      it "returns a global variable" do
        variable = @client.variable("test_var")

        expect(variable).to be_a(Variable)
        expect(variable.name).to eq("test_var")
        expect(variable.scope).to be_a(Scope::Global)
      end
    end

    describe "#builtin_variable" do
      it "returns a builtin variable" do
        variable = @client.builtin_variable("beval_col")

        expect(variable).to be_a(Variable)
        expect(variable.name).to eq("beval_col")
        expect(variable.scope).to be_a(Scope::Builtin)
      end
    end

    describe "#option" do
      it "returns an option" do
        option = @client.option("hlsearch")

        expect(option).to be_a(Option)
        expect(option.name).to eq("hlsearch")
        expect(option.scope).to be_a(Scope::Global)
      end
    end
  end
end
