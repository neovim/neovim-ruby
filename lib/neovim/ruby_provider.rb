require "neovim/ruby_provider/vim"
require "neovim/ruby_provider/object_ext"
require "neovim/ruby_provider/buffer_ext"
require "neovim/ruby_provider/window_ext"
require "stringio"

module Neovim
  # This class is used to define a +Neovim::Plugin+ to act as a backend for the
  # +:ruby+, +:rubyfile+, and +:rubydo+ Vim commands. It is autoloaded from
  # +nvim+ and not intended to be required directly.
  #
  # @api private
  module RubyProvider
    def self.__define_plugin!
      Thread.abort_on_exception = true

      Neovim.plugin do |plug|
        plug.__send__(:script_host!)

        __define_setup(plug)
        __define_ruby_execute(plug)
        __define_ruby_eval(plug)
        __define_ruby_execute_file(plug)
        __define_ruby_do_range(plug)
        __define_ruby_chdir(plug)
      end
    end

    # Define the +DirChanged+ event to update the provider's pwd.
    def self.__define_setup(plug)
      plug.__send__(:setup) do |client|
        begin
          cid = client.api.channel_id
          client.command("au DirChanged * call rpcrequest(#{cid}, 'ruby_chdir', v:event)")
        rescue ArgumentError
          # Swallow this exception for now. This means the nvim installation is
          # from before DirChanged was implemented.
        end
      end
    end

    # Evaluate the provided Ruby code, exposing the +Vim+ constant for
    # interactions with the editor.
    #
    # This is used by the +:ruby+ command.
    def self.__define_ruby_execute(plug)
      plug.__send__(:rpc, :ruby_execute) do |nvim, ruby|
        __wrap_client(nvim) do
          eval(ruby, TOPLEVEL_BINDING, "ruby_execute")
        end
        nil
      end
    end
    private_class_method :__define_ruby_execute

    # Evaluate the provided Ruby code, exposing the +Vim+ constant for
    # interactions with the editor and returning the value.
    #
    # This is used by the +:rubyeval+ command.
    def self.__define_ruby_eval(plug)
      plug.__send__(:rpc, :ruby_eval) do |nvim, ruby|
        __wrap_client(nvim) do
          eval(ruby, TOPLEVEL_BINDING, "ruby_eval")
        end
      end
    end
    private_class_method :__define_ruby_eval

    # Evaluate the provided Ruby file, exposing the +Vim+ constant for
    # interactions with the editor.
    #
    # This is used by the +:rubyfile+ command.
    def self.__define_ruby_execute_file(plug)
      plug.__send__(:rpc, :ruby_execute_file) do |nvim, path|
        __wrap_client(nvim) { load(path) }
        nil
      end
    end
    private_class_method :__define_ruby_execute_file

    # Evaluate the provided Ruby code over each line of a range. The contents
    # of the current line can be accessed and modified via the +$_+ variable.
    #
    # Since this method evaluates each line in the local binding, all local
    # variables and methods are available to the user. Thus the +__+ prefix
    # obfuscation.
    #
    # This is used by the +:rubydo+ command.
    def self.__define_ruby_do_range(__plug)
      __plug.__send__(:rpc, :ruby_do_range) do |__nvim, *__args|
        __wrap_client(__nvim) do
          __start, __stop, __ruby = __args
          __buffer = __nvim.get_current_buf

          __update_lines_in_chunks(__buffer, __start, __stop, 1_000) do |__lines|
            __lines.map do |__line|
              $_ = __line
              eval(__ruby, binding, "ruby_do_range")
              $_
            end
          end
        end
        nil
      end
    end
    private_class_method :__define_ruby_do_range

    def self.__define_ruby_chdir(plug)
      plug.__send__(:rpc, :ruby_chdir) do |_, event|
        Dir.chdir(event.fetch("cwd"))
      end
    end
    private_class_method :__define_ruby_chdir

    def self.__wrap_client(client)
      Vim.__client = client
      Vim.__refresh_globals(client)

      __with_exception_handling(client) do
        __with_std_streams(client) do
          yield
        end
      end
    end
    private_class_method :__wrap_client

    def self.__with_exception_handling(client)
      yield
    rescue ScriptError, StandardError => e
      msg = [e.class, e.message].join(": ")
      client.err_writeln(msg)
    end
    private_class_method :__with_exception_handling

    def self.__with_std_streams(client)
      old_stdout = $stdout.dup
      old_stderr = $stderr.dup

      $stdout, $stderr = StringIO.new, StringIO.new

      begin
        yield.tap do
          client.out_write($stdout.string + $/) if $stdout.size > 0
          client.err_writeln($stderr.string) if $stderr.size > 0
        end
      ensure
        $stdout = old_stdout
        $stderr = old_stderr
      end
    end
    private_class_method :__with_std_streams

    def self.__update_lines_in_chunks(buffer, start, stop, size)
      (start..stop).each_slice(size) do |linenos|
        start, stop = linenos[0] - 1, linenos[-1]
        lines = buffer.get_lines(start, stop, false)

        buffer.set_lines(start, stop, false, yield(lines))
      end
    end
    private_class_method :__update_lines_in_chunks
  end
end

Neovim::RubyProvider.__define_plugin!
