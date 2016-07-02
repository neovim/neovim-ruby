class VIM < BasicObject
  class << self
    attr_accessor :__client
  end

  Buffer = ::Neovim::Buffer
  Window = ::Neovim::Window

  def self.method_missing(method, *args, &block)
    @__client.public_send(method, *args, &block)
  end
end

module Neovim
  # Make +VIM::Buffer.current+ return the current buffer.
  class Buffer
    def self.current
      ::VIM.current.buffer
    end
  end

  # Make +VIM::Window.current+ return the current buffer.
  class Window
    def self.current
      ::VIM.current.window
    end
  end

  module RubyProvider
    def self.define_plugin!
      Neovim.plugin do |plug|
        define_ruby_execute(plug)
        define_ruby_execute_file(plug)
        define_ruby_do_range(plug)
      end
    end

    def self.define_ruby_execute(plug)
      plug.rpc(:ruby_execute, sync: true) do |nvim, ruby|
        wrap_client(nvim) do
          eval(ruby, binding, __FILE__, __LINE__)
          true
        end
      end
    end
    private_class_method :define_ruby_execute

    def self.define_ruby_execute_file(plug)
      plug.rpc(:ruby_execute_file, sync: true) do |nvim, path|
        wrap_client(nvim) do
          eval(File.read(path), binding, __FILE__, __LINE__)
          true
        end
      end
    end
    private_class_method :define_ruby_execute_file

    def self.define_ruby_do_range(plug)
      plug.rpc(:ruby_do_range, sync: true) do |nvim, *args|
        begin
          start, stop, ruby = args
          buffer = nvim.current.buffer

          (start..stop).each_slice(5000) do |linenos|
            _start, _stop = linenos[0]-1, linenos[-1]
            lines = buffer.get_lines(_start, _stop, true)

            lines.map! do |line|
              $_ = line
              eval(ruby, binding, __FILE__, __LINE__)
              String($_)
            end

            buffer.set_lines(_start, _stop, true, lines)
          end
        ensure
          $_ = nil
        end

        true
      end
    end
    private_class_method :define_ruby_do_range

    def self.wrap_client(client)
      begin
        $curwin = client.current.window
        $curbuf = client.current.buffer
        ::VIM.__client = client
        yield
      ensure
        $curwin = $curbuf = ::VIM.__client = nil
      end
    end
    private_class_method :wrap_client
  end
end

Neovim::RubyProvider.define_plugin!
