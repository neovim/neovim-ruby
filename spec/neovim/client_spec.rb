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

      client.current_line = ""
    end

    describe "#message" do
      it "prints a message to neovim" do
        pending "Nothing is in place to allow us to test this yet"
      end

      it "returns nil on success" do
        expect(client.message("test\n")).to be_nil
      end
    end

    describe "#set_option" do
      it "sets the provided option" do
        pending "Nothing is in place to allow us to test this yet"
      end

      it "returns nil on success" do
        expect(client.set_option("background", "light")).to be_nil
      end
    end

    describe "#command" do
      it "runs the provided command" do
        pending "Nothing is in place to allow us to test this yet"
      end

      it "returns nil on success" do
        expect(client.command('echo "Hello"')).to be_nil
      end
    end

    describe "#evaluate" do
      it "evaluates the provided vim expression" do
        pending "Nothing is in place to allow us to test this yet"
      end

      it "returns nil on success" do
        pending "raises 'Segmentation fault: 11'"
        expect(client.evaluate("ihello")).to be_nil
      end
    end

    describe "#push_keys" do
      it "pushes the provided keys" do
        pending "Nothing is in place to allow us to test this yet"
      end

      it "returns nil on success" do
        pending "raises 'Abort trap: 6'"
        expect(client.push_keys("ihello")).to be_nil
      end
    end

    describe "#push_keys" do
      it "pushes the provided keys" do
        pending "Nothing is in place to allow us to test this yet"
      end

      it "returns nil on success" do
        pending "raises 'Abort trap: 6'"
        expect(client.push_keys("ihello")).to be_nil
      end
    end

    describe "#strwidth" do
      it "returns the string cell width" do
        expect(client.strwidth("string")).to eq(6)
      end
    end

    describe "#runtime_paths" do
      it "returns an array of runtime paths" do
        expect(client.runtime_paths).to respond_to(:to_ary)
      end
    end

    describe "#change_directory" do
      it "changes the neovim working directory" do
        pending "Nothing is in place to allow us to test this yet"
      end

      it "returns nil on success" do
        pending "This fails every time for some reason"
        expect(client.change_directory("..")).to be_nil
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

      it "returns the content" do
        expect(client.current_line = "New content").to eq("New content")
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

    describe "#delete_current_line" do
      it "deletes the current line" do
        pending "Need control over multiple lines to test this"
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
        variable = client.option("hlsearch")
        expect(variable.name).to eq("hlsearch")
      end
    end
  end
end
