Thread.abort_on_exception = true

require "neovim/ruby_provider/vim"
require "neovim/ruby_provider/buffer_ext"
require "neovim/ruby_provider/window_ext"

module Neovim
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
          TOPLEVEL_BINDING.eval(ruby, __FILE__, __LINE__)
        end
      end
    end
    private_class_method :define_ruby_execute

    def self.define_ruby_execute_file(plug)
      plug.rpc(:ruby_execute_file, sync: true) do |nvim, path|
        wrap_client(nvim) { load(path) }
      end
    end
    private_class_method :define_ruby_execute_file

    def self.define_ruby_do_range(plug)
      plug.rpc(:ruby_do_range, sync: true) do |nvim, *args|
        wrap_client(nvim) do
          start, stop, ruby = args
          buffer = nvim.get_current_buffer

          update_lines_in_chunks(buffer, start, stop, 5000) do |lines|
            lines.map do |line|
              TOPLEVEL_BINDING.eval("$_ = #{line.inspect}")
              TOPLEVEL_BINDING.eval(ruby, __FILE__, __LINE__)
              TOPLEVEL_BINDING.eval("$_")
            end
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
      $curbuf = client.get_current_buffer
      $curwin = client.get_current_window
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

    def self.update_lines_in_chunks(buffer, start, stop, size)
      (start..stop).each_slice(size) do |linenos|
        _start, _stop = linenos[0]-1, linenos[-1]
        lines = buffer.get_lines(_start, _stop, true)

        buffer.set_lines(_start, _stop, true, yield(lines))
      end
    end
    private_class_method :update_lines_in_chunks
  end
end

Neovim::RubyProvider.define_plugin!
