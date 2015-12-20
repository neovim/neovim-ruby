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
        expect(handler.to_spec).to eq(
          :type => :command,
          :name => :Foo,
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
        expect(handler.to_spec).to eq(
          :type => :autocmd,
          :name => :BufEnter,
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
        expect(handler.to_spec).to eq(
          :type => :function,
          :name => :Foo,
          :sync => false,
          :opts => {:range => "", :nargs => 1},
        )
      end
    end
  end
end
