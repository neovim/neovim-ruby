require "neovim/logging"
require "socket"
require "msgpack"

module Neovim
  # @api private
  class Connection
    include Logging

    def self.tcp(host, port)
      socket = Socket.tcp(host, port)
      new(socket, socket)
    end

    def self.unix(path)
      socket = Socket.unix(path)
      new(socket, socket)
    end

    def self.child(argv)
      argv = argv.include?("--embed") ? argv : argv + ["--embed"]

      io = ::IO.popen(argv, "rb+")
      Process.detach(io.pid)

      new(io, io)
    end

    def self.stdio
      new(STDIN, STDOUT)
    end

    def initialize(rd, wr)
      @rd, @wr = [rd, wr].each { |io| io.binmode.sync = true }

      @unpacker = MessagePack::Unpacker.new(@rd)
      @packer = MessagePack::Packer.new(@wr)
    end

    def write(object)
      log(:debug) { {object: object} }
      @packer.write(object)
      self
    end

    def read
      @unpacker.read.tap do |object|
        log(:debug) { {object: object} }
      end
    end

    def flush
      @packer.flush
      self
    end

    def register_type(id)
      @unpacker.register_type(id) do |data|
        index = MessagePack.unpack(data)
        yield index
      end
    end

    def close
      [@rd, @wr].each do |io|
        begin
          io.close
        rescue ::IOError
        end
      end
    end
  end
end
