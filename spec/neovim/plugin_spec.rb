require "helper"

module Neovim
  RSpec.describe Plugin do
    describe ".from_config_block" do
      it "registers a command" do
        cmd_block = Proc.new {}

        plugin = Plugin.from_config_block("source") do |plug|
          plug.command("Foo", :range => true, :nargs => 1, &cmd_block)
        end

        expect(plugin.handlers.size).to be(1)
        handler = plugin.handlers.first

        expect(handler.block).to eq(cmd_block)
        expect(handler.qualified_name).to eq("source:command:Foo")
        expect(handler.to_spec).to eq(
          :type => :command,
          :name => "Foo",
          :sync => false,
          :opts => {:range => "", :nargs => 1},
        )
      end

      it "registers an autocmd" do
        au_block = Proc.new {}

        plugin = Plugin.from_config_block("source") do |plug|
          plug.autocmd("BufEnter", :pattern => "*.rb", &au_block)
        end

        expect(plugin.handlers.size).to be(1)
        handler = plugin.handlers.first

        expect(handler.block).to eq(au_block)
        expect(handler.qualified_name).to eq("source:autocmd:BufEnter:*.rb")
        expect(handler.to_spec).to eq(
          :type => :autocmd,
          :name => "BufEnter",
          :sync => false,
          :opts => {:pattern => "*.rb"},
        )
      end

      it "registers a function" do
        fun_block = Proc.new {}

        plugin = Plugin.from_config_block("source") do |plug|
          plug.function("Foo", :range => true, :nargs => 1, &fun_block)
        end

        expect(plugin.handlers.size).to be(1)
        handler = plugin.handlers.first

        expect(handler.block).to eq(fun_block)
        expect(handler.qualified_name).to eq("source:function:Foo")
        expect(handler.to_spec).to eq(
          :type => :function,
          :name => "Foo",
          :sync => false,
          :opts => {:range => "", :nargs => 1},
        )
      end

      it "registers a top level RPC" do
        cmd_block = Proc.new {}

        plugin = Plugin.from_config_block("source") do |plug|
          plug.__send__(:rpc, "Foo", &cmd_block)
        end

        expect(plugin.handlers.size).to be(1)
        handler = plugin.handlers.first

        expect(handler.block).to eq(cmd_block)
        expect(handler.qualified_name).to eq("Foo")
      end
    end

    describe "#specs" do
      it "returns specs for plugin handlers" do
        plugin = Plugin.from_config_block("source") do |plug|
          plug.command("Foo", :sync => true, :nargs => 2)
        end

        expect(plugin.specs).to eq(
          [
            {
              :type => :command,
              :name => "Foo",
              :sync => true,
              :opts=> {:nargs => 2}
            }
          ]
        )
      end

      it "doesn't include specs for top-level RPCs" do
        plugin = Plugin.from_config_block("source") do |plug|
          plug.__send__(:rpc, "Foo")
        end

        expect(plugin.specs).to eq([])
      end
    end
  end
end
