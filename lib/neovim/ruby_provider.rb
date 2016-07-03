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
        end
      end
    end
    private_class_method :define_ruby_execute

    def self.define_ruby_execute_file(plug)
      plug.rpc(:ruby_execute_file, sync: true) do |nvim, path|
        wrap_client(nvim) do
          eval(File.read(path), binding, __FILE__, __LINE__)
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
      end
    end
    private_class_method :define_ruby_do_range

    def self.wrap_client(client)
      with_globals(client) do
        with_vim_constant(client) do
          with_redirect_streams(client) do
            yield
          end
        end
      end
    end
    private_class_method :wrap_client

    def self.with_globals(client)
      $curwin = client.current.window
      $curbuf = client.current.buffer

      begin
        yield
      ensure
        $curwin = $curbuf = nil
      end
    end
    private_class_method :with_globals

    def self.with_vim_constant(client)
      ::VIM.__client = client

      begin
        yield
      ensure
        ::VIM.__client = nil
      end
    end
    private_class_method :with_vim_constant

    def self.with_redirect_streams(client)
      old_out_write = $stdout.method(:write)
      old_err_write = $stderr.method(:write)

      $stdout.define_singleton_method(:write) do |string|
        client.out_write(string)
      end

      $stderr.define_singleton_method(:write) do |string|
        client.err_write(string)
      end

      begin
        yield
      ensure
        $stdout.define_singleton_method(:write, &old_out_write)
        $stderr.define_singleton_method(:write, &old_err_write)
      end
    end
    private_class_method :with_redirect_streams
  end
end

Neovim::RubyProvider.define_plugin!
