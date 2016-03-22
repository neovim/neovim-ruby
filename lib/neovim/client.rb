require "neovim/current"

module Neovim
  class Client
    attr_reader :session

    def initialize(session)
      @session = session
      @api = session.api
    end

    def method_missing(method_name, *args)
      if func = @api.function("vim_#{method_name}")
        func.call(session, *args)
      else
        super
      end
    end

    def respond_to?(method_name)
      super || rpc_methods.include?(method_name.to_sym)
    end

    def methods
      super | rpc_methods
    end

    def current
      Current.new(@session)
    end

    private

    def rpc_methods
      @api.functions_with_prefix("vim_").map do |func|
        func.name.sub(/\Avim_/, "").to_sym
      end
    end

    public

# The following methods are dynamically generated.
=begin
@!method command(str)
  @param [String] str
  @return [void]

@!method feedkeys(keys, mode, escape_csi)
  @param [String] keys
  @param [String] mode
  @param [Boolean] escape_csi
  @return [void]

@!method input(keys)
  @param [String] keys
  @return [Fixnum]

@!method replace_termcodes(str, from_part, do_lt, special)
  @param [String] str
  @param [Boolean] from_part
  @param [Boolean] do_lt
  @param [Boolean] special
  @return [String]

@!method command_output(str)
  @param [String] str
  @return [String]

@!method eval(str)
  @param [String] str
  @return [Object]

@!method call_function(fname, args)
  @param [String] fname
  @param [Array] args
  @return [Object]

@!method strwidth(str)
  @param [String] str
  @return [Fixnum]

@!method list_runtime_paths
  @return [Array<String>]

@!method change_directory(dir)
  @param [String] dir
  @return [void]

@!method get_current_line
  @return [String]

@!method set_current_line(line)
  @param [String] line
  @return [void]

@!method del_current_line
  @return [void]

@!method get_var(name)
  @param [String] name
  @return [Object]

@!method set_var(name, value)
  @param [String] name
  @param [Object] value
  @return [Object]

@!method get_vvar(name)
  @param [String] name
  @return [Object]

@!method get_option(name)
  @param [String] name
  @return [Object]

@!method set_option(name, value)
  @param [String] name
  @param [Object] value
  @return [void]

@!method out_write(str)
  @param [String] str
  @return [void]

@!method err_write(str)
  @param [String] str
  @return [void]

@!method report_error(str)
  @param [String] str
  @return [void]

@!method get_buffers
  @return [Array<Buffer>]

@!method get_current_buffer
  @return [Buffer]

@!method set_current_buffer(buffer)
  @param [Buffer] buffer
  @return [void]

@!method get_windows
  @return [Array<Window>]

@!method get_current_window
  @return [Window]

@!method set_current_window(window)
  @param [Window] window
  @return [void]

@!method get_tabpages
  @return [Array<Tabpage>]

@!method get_current_tabpage
  @return [Tabpage]

@!method set_current_tabpage(tabpage)
  @param [Tabpage] tabpage
  @return [void]

@!method subscribe(event)
  @param [String] event
  @return [void]

@!method unsubscribe(event)
  @param [String] event
  @return [void]

@!method name_to_color(name)
  @param [String] name
  @return [Fixnum]

@!method get_color_map
  @return [Dictionary]

@!method get_api_info
  @return [Array]

=end
  end
end
