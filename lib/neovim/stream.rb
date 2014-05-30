require "libuv"

module Neovim
  class Stream
    class Timeout < RuntimeError; end

    def initialize(address, port)
      @loop = ::Libuv::Loop.new
      @timer = create_timer

      create_uv_stream(address, port)
    end

    def read
      run_until { @connected }
      @data = nil

      @uv.start_read
      run_until { @data }
      @uv.stop_read

      result = @data
      @data = nil
      result
    end

    def write(data)
      run_until { @connected }
      @written = false

      @uv.write(data).then do
        @written = true
      end

      run_until { @written }
    end

    private

    def create_uv_stream(address, port)
      raise("TCP not supported yet") if port

      @loop.pipe.connect(address) do |pipe|
        pipe.progress { |data| @data = data }

        @uv = pipe
        @connected = true
      end
    end

    def create_timer
      @loop.timer do
        @timeout = true
        @loop.stop
      end
    end

    def run_until(timeout=1000, &condition)
      @timer.start(timeout)
      @loop.run(:UV_RUN_ONCE) until condition.call || @timeout
      @timer.stop
      raise Timeout.new("Timeout of #{timeout}ms exceeded.") if @timeout
    end
  end
end
