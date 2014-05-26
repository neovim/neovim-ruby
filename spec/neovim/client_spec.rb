# coding: utf-8
require "helper"
require "neovim/client"

module Neovim
  describe Client do
    let(:client) { Client.new(socket_path) }

    let(:socket_path) do
      ENV.fetch("NEOVIM_LISTEN_ADDRESS", "/tmp/neovim.sock")
    end

    before do
      unless File.socket?(socket_path)
        raise("Neovim isn't running. Run it with `NEOVIM_LISTEN_ADDRESS=#{socket_path} nvim`")
      end

      client.option("background").value = "dark"
      client.current_line = ""
    end

    describe "#message" do
      it "prints a message to neovim" do
        client.message("This is a message")
        pending "Still deciding how to test this (also it doesn't work)"
      end
    end

    describe "#error" do
      it "prints an error message to neovim" do
        client.error("This is an error message")
        pending "Still deciding how to test this (also it doesn't work)"
      end
    end

    describe "#set_option" do
      it "sets the provided option" do
        expect {
          client.set_option("background", "light")
        }.to change { client.option("background").value }.from("dark").to("light")
      end
    end

    describe "#command" do
      it "runs the provided command" do
        expect {
          client.command("set background=light")
        }.to change { client.option("background").value }.from("dark").to("light")
      end
    end

    describe "#evaluate" do
      it "evaluates the provided vim expression" do
        client.command("let g:v1 = \"a\"")
        client.command("let g:v2 = [1, 2]")

        expect(client.evaluate("g:")).to eq("v1" => "a", "v2" => [1, 2])
      end
    end

    describe "#push_keys" do
      it "pushes keys" do
        pending "This just blows up, punting for now."
      end
    end

    describe "#strwidth" do
      it "returns the string cell width" do
        expect(client.strwidth("テスト")).to eq(6)
      end
    end

    describe "#runtime_paths" do
      it "returns an array of runtime paths" do
        expect(client.runtime_paths).to respond_to(:to_ary)
      end
    end

    describe "#change_directory" do
      it "changes the neovim working directory" do
        pending "Still deciding how to test this"
      end

      it "raises an exception on failure" do
        expect {
          client.change_directory("/this/directory/doesnt/exist")
        }.to raise_error(Neovim::RPC::Error, /failed.+change directory/i)
      end
    end

    describe "#current_line=" do
      it "sets the content of the current line" do
        client.current_line = "New content"
        expect(client.current_line).to eq("New content")
      end

      it "returns the new content" do
        expect(client.current_line = "New content").to eq("New content")
      end

      it "empties the line" do
        client.current_line = "New content"
        client.current_line = ""
        expect(client.current_line).to eq("")
      end
    end

    describe "#current_line" do
      it "returns an empty string if the current line is empty" do
        expect(client.current_line).to eq("")
      end

      it "returns the contents of the line" do
        client.current_line = "New content"
        expect(client.current_line).to eq("New content")
      end
    end

    describe "#variable" do
      it "returns a global variable" do
        variable = client.variable("g:test_var")
        expect(variable.name).to eq("test_var")
        expect(variable.value).to be_nil
      end

      it "returns a builtin variable" do
        variable = client.variable("v:beval_col")
        expect(variable.name).to eq("beval_col")
        expect(variable.value).to eq(0)
      end
    end

    describe "#option" do
      it "returns an option" do
        option = client.option("hlsearch")
        expect(option.name).to eq("hlsearch")
        expect(option.value).to eq(false)
      end
    end
  end
end
