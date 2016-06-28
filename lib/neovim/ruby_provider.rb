require "delegate"

# Make the +Vim+ constant delegate to a Neovim::Client instance.
class ClientDelegator < SimpleDelegator
  def initialize
    super(nil)
  end

  def Buffer
    ::Neovim::Buffer
  end

  def Window
    ::Neovim::Window
  end
end

Vim = ClientDelegator.new

module Neovim
  # Make +Vim::Buffer.current+ return the current buffer.
  class Buffer
    def self.current
      ::Vim.current.buffer
    end
  end

  # Make +Vim::Window.current+ return the current buffer.
  class Window
    def self.current
      ::Vim.current.window
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
      plug.rpc(:ruby_execute, sync: true) do |nvim, *args|
        ruby, start, stop = args
        nvim.current.range = (start-1..stop-1)

        wrap_client(nvim) do
          eval(ruby, binding, __FILE__, __LINE__)
        end
      end
    end
    private_class_method :define_ruby_execute

    def self.define_ruby_execute_file(plug)
      plug.rpc(:ruby_execute_file, sync: true) do |nvim, *args|
        path, start, stop = args
        nvim.current.range = (start-1..stop-1)

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
      begin
        ::Vim.__setobj__(client)
        yield
      ensure
        ::Vim.__setobj__(nil)
      end
    end
    private_class_method :wrap_client
  end
end

Neovim::RubyProvider.define_plugin!
