require "neovim/logging"
require "socket"
require "msgpack"

module Neovim
  # The lowest level interface to reading from and writing to +nvim+.
  #
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

    def self.child(_argv)
      argv = _argv.include?("--embed") ? _argv : _argv + ["--embed"]

      io = ::IO.popen(argv, "rb+").tap do |_io|
        Process.detach(_io.pid)
      end

      new(io, io)
    end

    def self.stdio
      new(STDIN, STDOUT)
    end

    def initialize(rd, wr)
      @rd, @wr = [rd, wr].each { |io| io.binmode.sync = true }

      @unpacker = MessagePack::Unpacker.new(@rd)
      @packer = MessagePack::Packer.new(@wr)
      @running = false
    end

    # Write object to the underlying +IO+ as msgpack.
    def write(object)
      log(:debug) { {:object => object} }
      @packer.write(object).flush
    end

    def read
      @unpacker.read.tap do |object|
        log(:debug) { {:object => object} }
      end
    end

    def register_type(id, &block)
      @unpacker.register_type(id) do |data|
        index = MessagePack.unpack(data)
        block.call(index)
      end
    end

    # Close underlying +IO+s.
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
