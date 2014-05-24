require "libuv"

module Neovim
  class Stream
    def initialize(address, port)
      @loop = ::Libuv::Loop.default
      create_uv_stream(address, port, @loop)
    end

    def read
      run_until { @connected }
      @data = nil

      @uv.progress do |data|
        @data = data
      end

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

    def create_uv_stream(address, port, loop)
      raise("TCP not supported yet") if port

      loop.pipe.connect(address) do |pipe|
        @connected = true
        @uv = pipe
      end
    end

    def run_until(&condition)
      until result = condition.call
        @loop.run(:UV_RUN_ONCE)
      end
    end
  end
end
