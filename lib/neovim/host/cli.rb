require "neovim/connection"
require "neovim/event_loop"
require "neovim/host"
require "neovim/version"
require "optparse"

module Neovim
  class Host
    # @api private
    class CLI
      def self.run(path, argv, inn, out, err)
        cmd = File.basename(path)

        OptionParser.new do |opts|
          opts.on("-V", "--version") do
            out.puts Neovim::VERSION
            exit(0)
          end

          opts.on("-h", "--help") do
            out.puts "Usage: #{cmd} [-hV] rplugin_path ..."
            exit(0)
          end
        end.order!(argv)

        if inn.tty?
          err.puts("Can't run #{cmd} interactively.")
          exit(1)
        else
          conn = Connection.new(inn, out)
          event_loop = EventLoop.new(conn)

          Host.run(argv, event_loop)
        end
      rescue OptionParser::InvalidOption => e
        err.puts(e.message)
        exit(1)
      end
    end
  end
end
