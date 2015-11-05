require "helper"

module Neovim
  RSpec.describe Plugin do
    describe ".from_config_block" do
      it "registers a command" do
        cmd_block = Proc.new {}

        plugin = Plugin.from_config_block do |plug|
          plug.command("Foo", :range => true, :nargs => 1, &cmd_block)
        end

        expect(plugin.specs).to eq(
          [
            {
              :type => :command,
              :name => :Foo,
              :sync => false,
              :opts => {:range => "", :nargs => 1},
              :proc => cmd_block
            }
          ]
        )
      end

      it "registers an autocmd" do
        au_block = Proc.new {}

        plugin = Plugin.from_config_block do |plug|
          plug.autocmd("BufEnter", :pattern => "*.rb", &au_block)
        end

        expect(plugin.specs).to eq(
          [
            {
              :type => :autocmd,
              :name => :BufEnter,
              :sync => false,
              :opts => {:pattern => "*.rb"},
              :proc => au_block
            }
          ]
        )
      end

      it "registers a function" do
        fun_block = Proc.new {}

        plugin = Plugin.from_config_block do |plug|
          plug.function("Foo", :range => true, :nargs => 1, &fun_block)
        end

        expect(plugin.specs).to eq(
          [
            {
              :type => :function,
              :name => :Foo,
              :sync => false,
              :opts => {:range => "", :nargs => 1},
              :proc => fun_block
            }
          ]
        )
      end
    end
  end
end
