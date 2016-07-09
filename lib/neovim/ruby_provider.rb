$__ruby_provider_scope = binding
Thread.abort_on_exception = true

class VIM < BasicObject
  class << self
    attr_accessor :__client
    attr_writer :__parent_thread
  end

  Buffer = ::Neovim::Buffer
  Window = ::Neovim::Window

  self.__parent_thread = ::Thread.current

  def self.method_missing(method, *args, &block)
    if @__parent_thread == ::Thread.current
      @__client.public_send(method, *args, &block)
    else
      raise(
        "A Ruby plugin attempted to call neovim outside of the main thread, " +
        "which is not yet supported by the neovim gem."
      )
    end
  end
end

module Neovim
  # Make +VIM::Buffer.current+ return the current buffer.
  class Buffer
    def self.current
      ::VIM.current.buffer
    end

    def self.count
      ::VIM.get_buffers.size
    end

    def self.[](index)
      ::VIM.get_buffers[index]
    end
  end

  # Make +VIM::Window.current+ return the current buffer.
  class Window
    def self.current
      ::VIM.current.window
    end

    def self.count
      ::VIM.get_windows.size
    end

    def self.[](index)
      ::VIM.get_windows[index]
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
          $__ruby_provider_scope.eval(ruby, __FILE__, __LINE__)
        end
      end
    end
    private_class_method :define_ruby_execute

    def self.define_ruby_execute_file(plug)
      plug.rpc(:ruby_execute_file, sync: true) do |nvim, path|
        wrap_client(nvim) do
          $__ruby_provider_scope.eval(File.read(path), __FILE__, __LINE__)
        end
      end
    end
    private_class_method :define_ruby_execute_file

    def self.define_ruby_do_range(plug)
      plug.rpc(:ruby_do_range, sync: true) do |nvim, *args|
        wrap_client(nvim) do
          start, stop, ruby = args
          buffer = nvim.current.buffer

          (start..stop).each_slice(5000) do |linenos|
            _start, _stop = linenos[0]-1, linenos[-1]
            lines = buffer.get_lines(_start, _stop, true)

            lines.map! do |line|
              $__ruby_provider_scope.eval("$_ = #{line.inspect}")
              $__ruby_provider_scope.eval(ruby, __FILE__, __LINE__)
              $__ruby_provider_scope.eval("$_")
            end

            buffer.set_lines(_start, _stop, true, lines)
          end
        end
      end
    end
    private_class_method :define_ruby_do_range

    def self.wrap_client(__client)
      with_globals(__client) do
        with_vim_constant(__client) do
          with_redirect_streams(__client) do
            yield
          end
        end
      end
      nil
    end
    private_class_method :wrap_client

    def self.with_globals(client)
      $curbuf = client.current.buffer
      $curwin = client.current.window
      yield
    end
    private_class_method :with_globals

    def self.with_vim_constant(client)
      ::VIM.__client = client
      yield
    end
    private_class_method :with_vim_constant

    def self.with_redirect_streams(client)
      @with_redirect_streams ||= begin
        old_out_write = $stdout.method(:write)
        old_err_write = $stderr.method(:write)

        $stdout.define_singleton_method(:write) do |string|
          client.out_write(string)
        end

        $stderr.define_singleton_method(:write) do |string|
          client.err_write(string)
        end

        true
      end

      yield
    end
    private_class_method :with_redirect_streams
  end
end

Neovim::RubyProvider.define_plugin!
