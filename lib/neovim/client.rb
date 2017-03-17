require "neovim/current"

module Neovim
  # Client to a running +nvim+ instance. The interface is generated at
  # runtime via the +vim_get_api_info+ RPC call. Some methods return
  # +RemoteObject+ subclasses (i.e. +Buffer+, +Window+, or +Tabpage+),
  # which similarly have dynamically generated interfaces.
  #
  # @see Buffer
  # @see Window
  # @see Tabpage
  class Client
    attr_reader :session, :channel_id

    def initialize(session)
      session.discover_api

      @session = session
      @api = session.api
      @channel_id = session.channel_id
    end

    # Intercept method calls and delegate to appropriate RPC methods.
    def method_missing(method_name, *args)
      if func = @api.function("vim_#{method_name}")
        func.call(@session, *args)
      else
        super
      end
    end

    # Extend +respond_to?+ to support RPC methods.
    def respond_to?(method_name)
      super || rpc_methods.include?(method_name.to_sym)
    end

    # Extend +methods+ to include RPC methods.
    def methods
      super | rpc_methods
    end

    # Access to objects belonging to the current +nvim+ context.
    #
    # @return [Current]
    # @example Get the current buffer
    #   client.current.buffer
    # @example Set the current line
    #   client.current.line = "New line"
    # @see Current
    def current
      @current ||= Current.new(@session)
    end

    # Evaluate the VimL expression (alias for +vim_eval+).
    #
    # @param expr [String] A VimL expression.
    # @return [Object]
    # @example Return a list from VimL
    #   client.evaluate('[1, 2]') # => [1, 2]
    def evaluate(expr)
      @api.function(:vim_eval).call(@session, expr)
    end

    # Display a message.
    #
    # @param string [String] The message.
    # @return [void]
    def message(string)
      out_write(string)
    end

    # Set an option.
    #
    # @overload set_option(key, value)
    #   @param [String] key
    #   @param [String] value
    #
    # @overload set_option(optstr)
    #   @param [String] optstr
    #
    # @example Set the +timeoutlen+ option
    #   client.set_option("timeoutlen", 0)
    #   client.set_option("timeoutlen=0")
    def set_option(*args)
      if args.size > 1
        @api.function("vim_set_option").call(@session, *args)
      else
        @api.function("vim_command").call(@session, "set #{args.first}")
      end
    end

    def shutdown
      @session.shutdown
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
@method set_var(name, value)
  Send the +vim_set_var+ RPC to +nvim+
  @param [String] name
  @param [Object] value
  @return [Object]

@method del_var(name)
  Send the +vim_del_var+ RPC to +nvim+
  @param [String] name
  @return [Object]

@method command(command)
  Send the +vim_command+ RPC to +nvim+
  @param [String] command
  @return [void]

@method feedkeys(keys, mode, escape_csi)
  Send the +vim_feedkeys+ RPC to +nvim+
  @param [String] keys
  @param [String] mode
  @param [Boolean] escape_csi
  @return [void]

@method input(keys)
  Send the +vim_input+ RPC to +nvim+
  @param [String] keys
  @return [Integer]

@method replace_termcodes(str, from_part, do_lt, special)
  Send the +vim_replace_termcodes+ RPC to +nvim+
  @param [String] str
  @param [Boolean] from_part
  @param [Boolean] do_lt
  @param [Boolean] special
  @return [String]

@method command_output(str)
  Send the +vim_command_output+ RPC to +nvim+
  @param [String] str
  @return [String]

@method eval(expr)
  Send the +vim_eval+ RPC to +nvim+
  @param [String] expr
  @return [Object]

@method call_function(fname, args)
  Send the +vim_call_function+ RPC to +nvim+
  @param [String] fname
  @param [Array] args
  @return [Object]

@method strwidth(str)
  Send the +vim_strwidth+ RPC to +nvim+
  @param [String] str
  @return [Integer]

@method list_runtime_paths
  Send the +vim_list_runtime_paths+ RPC to +nvim+
  @return [Array<String>]

@method change_directory(dir)
  Send the +vim_change_directory+ RPC to +nvim+
  @param [String] dir
  @return [void]

@method get_current_line
  Send the +vim_get_current_line+ RPC to +nvim+
  @return [String]

@method set_current_line(line)
  Send the +vim_set_current_line+ RPC to +nvim+
  @param [String] line
  @return [void]

@method del_current_line
  Send the +vim_del_current_line+ RPC to +nvim+
  @return [void]

@method get_var(name)
  Send the +vim_get_var+ RPC to +nvim+
  @param [String] name
  @return [Object]

@method get_vvar(name)
  Send the +vim_get_vvar+ RPC to +nvim+
  @param [String] name
  @return [Object]

@method get_option(name)
  Send the +vim_get_option+ RPC to +nvim+
  @param [String] name
  @return [Object]

@method out_write(str)
  Send the +vim_out_write+ RPC to +nvim+
  @param [String] str
  @return [void]

@method err_write(str)
  Send the +vim_err_write+ RPC to +nvim+
  @param [String] str
  @return [void]

@method report_error(str)
  Send the +vim_report_error+ RPC to +nvim+
  @param [String] str
  @return [void]

@method get_buffers
  Send the +vim_get_buffers+ RPC to +nvim+
  @return [Array<Buffer>]

@method get_current_buffer
  Send the +vim_get_current_buffer+ RPC to +nvim+
  @return [Buffer]

@method set_current_buffer(buffer)
  Send the +vim_set_current_buffer+ RPC to +nvim+
  @param [Buffer] buffer
  @return [void]

@method get_windows
  Send the +vim_get_windows+ RPC to +nvim+
  @return [Array<Window>]

@method get_current_window
  Send the +vim_get_current_window+ RPC to +nvim+
  @return [Window]

@method set_current_window(window)
  Send the +vim_set_current_window+ RPC to +nvim+
  @param [Window] window
  @return [void]

@method get_tabpages
  Send the +vim_get_tabpages+ RPC to +nvim+
  @return [Array<Tabpage>]

@method get_current_tabpage
  Send the +vim_get_current_tabpage+ RPC to +nvim+
  @return [Tabpage]

@method set_current_tabpage(tabpage)
  Send the +vim_set_current_tabpage+ RPC to +nvim+
  @param [Tabpage] tabpage
  @return [void]

@method subscribe(event)
  Send the +vim_subscribe+ RPC to +nvim+
  @param [String] event
  @return [void]

@method unsubscribe(event)
  Send the +vim_unsubscribe+ RPC to +nvim+
  @param [String] event
  @return [void]

@method name_to_color(name)
  Send the +vim_name_to_color+ RPC to +nvim+
  @param [String] name
  @return [Integer]

@method get_color_map
  Send the +vim_get_color_map+ RPC to +nvim+
  @return [Dictionary]

@method get_api_info
  Send the +vim_get_api_info+ RPC to +nvim+
  @return [Array]

=end
  end
end
