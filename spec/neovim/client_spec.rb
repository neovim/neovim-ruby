# coding: utf-8
require "helper"

module Neovim
  RSpec.describe Client, :remote do
    describe "#type_code_for" do
      it "returns the type code for buffers, windows, and tabpages" do
        expect(@client.type_code_for(Buffer)).to  respond_to(:to_int)
        expect(@client.type_code_for(Window)).to  respond_to(:to_int)
        expect(@client.type_code_for(Tabpage)).to respond_to(:to_int)
      end
    end

    describe "#class_for" do
      it "returns Buffer, Window, and Tabpage for their respective type codes" do
        buffer_type_code  = @client.type_code_for(Buffer)
        window_type_code  = @client.type_code_for(Window)
        tabpage_type_code = @client.type_code_for(Tabpage)

        expect(@client.class_for(buffer_type_code)).to  eq(Buffer)
        expect(@client.class_for(window_type_code)).to  eq(Window)
        expect(@client.class_for(tabpage_type_code)).to eq(Tabpage)
      end
    end

    describe "#message" do
      it "doesn't blow up" do
        @client.message("This is a message\n")
      end
    end

    describe "#error" do
      it "doesn't blow up" do
        @client.error("This is an error message\n")
      end
    end

    describe "#report_error" do
      it "doesn't blow up" do
        @client.report_error("error!")
      end
    end

    describe "#command" do
      it "runs the provided command" do
        expect {
          @client.command("set hlsearch")
        }.to change { @client.option("hlsearch").value }.from(false).to(true)
      end

      it "returns the client" do
        expect(@client.command("set hlsearch")).to eq(@client)
      end

      it "raises errors when command writes to err stream" do
        expect {
          @client.command("echoerr 'error!'")
        }.to raise_error(RPC::Error, /error!/)
      end
    end

    describe "#command_output" do
      it "returns the output of a command" do
        expect(@client.command_output("echom 'hi'")).to match(/hi/)
      end

      it "raises errors when command writes to err stream" do
        expect {
          @client.command_output("echoerr 'error!'")
        }.to raise_error(RPC::Error, /error!/)
      end
    end

    describe "#evaluate" do
      it "evaluates the provided vim expression" do
        @client.command("let g:v1 = \"a\"")
        @client.command("let g:v2 = [1, 2]")

        expect(@client.evaluate("g:")).to eq("v1" => "a", "v2" => [1, 2])
      end
    end

    describe "#feed_keys" do
      it "feeds keys in the provided mode" do
        @client.feed_keys("ihello", "m")
        expect(@client.current.buffer.lines.to_a).to eq(["hello"])
      end

      it "returns the client" do
        expect(@client.feed_keys("j", "m")).to eq(@client)
      end
    end

    describe "#input" do
      it "sends the provided keys" do
        pending "The input function takes several seconds to catch for some reason"
        @client.input("ihello")
        expect(@client.current.buffer.lines.to_a).to eq(["hello"])
      end

      it "returns the number of bytes written" do
        expect(@client.input("ihello")).to eq(6)
      end
    end

    describe "#strwidth" do
      it "returns the string cell width" do
        expect(@client.strwidth("テスト")).to eq(6)
      end
    end

    describe "#replace_termcodes" do
      it "replaces termcodes" do
        expect(@client.replace_termcodes("esc", true, true, true)).to eq("esc\e")
      end

      it "passes through" do
        expect(@client.replace_termcodes("hi", true, true, true)).to eq("hi")
      end
    end

    describe "#runtime_paths" do
      it "returns an array of runtime paths" do
        expect(@client.runtime_paths).to respond_to(:to_ary)
      end
    end

    describe "#change_directory" do
      it "changes the neovim working directory" do
        expect {
          @client.change_directory("..")
        }.to change { @client.evaluate("getcwd()") }
      end

      it "returns the client" do
        expect(@client.change_directory("..")).to eq(@client)
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

    describe "#delete_current_line" do
      before { @client.current.line = "hi" }

      it "deletes the current line" do
        expect {
          @client.delete_current_line
        }.to change { @client.current.line }.from("hi").to("")
      end
    end

    describe "#windows" do
      it "returns a list of windows" do
        windows = @client.windows
        expect(windows.size).to eq(1)
        expect(windows.first).to be_a(Window)
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

    describe "#register_provider" do
      it "registers a feature provider"
    end

    describe "#subscribe" do
      it "subscribes to events"
    end

    describe "#unsubscribe" do
      it "unsubscribes from events"
    end
  end
end
