require "neovim/current"

module Neovim
  # Client to a running +nvim+ instance. The interface is generated at
  # runtime via the +nvim_get_api_info+ RPC call. Some methods return
  # +RemoteObject+ subclasses (i.e. +Buffer+, +Window+, or +Tabpage+),
  # which similarly have dynamically generated interfaces.
  #
  # The methods documented here were generated using NVIM v0.2.0
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
      if func = @api.function_for_object_method(self, method_name)
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
    def methods(*args)
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

    # Evaluate the VimL expression (alias for +nvim_eval+).
    #
    # @param expr [String] A VimL expression.
    # @return [Object]
    # @example Return a list from VimL
    #   client.evaluate('[1, 2]') # => [1, 2]
    def evaluate(expr)
      @api.function_for_object_method(self, :eval).call(@session, expr)
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
        @api.function_for_object_method(self, :set_option).call(@session, *args)
      else
        @api.function_for_object_method(self, :command).call(@session, "set #{args.first}")
      end
    end

    def shutdown
      @session.shutdown
    end

    private

    def rpc_methods
      @api.functions_for_object(self).map(&:method_name)
    end

    public

# The following methods are dynamically generated.
=begin
@method ui_attach(height, options)
  See +:h nvim_ui_attach()+
  @param [Integer] height
  @param [Hash] options
  @return [void]

@method ui_detach
  See +:h nvim_ui_detach()+
  @return [void]

@method ui_try_resize(height)
  See +:h nvim_ui_try_resize()+
  @param [Integer] height
  @return [void]

@method ui_set_option(value)
  See +:h nvim_ui_set_option()+
  @param [Object] value
  @return [void]

@method command
  See +:h nvim_command()+
  @return [void]

@method feedkeys(mode, escape_csi)
  See +:h nvim_feedkeys()+
  @param [String] mode
  @param [Boolean] escape_csi
  @return [void]

@method input
  See +:h nvim_input()+
  @return [Integer]

@method replace_termcodes(from_part, do_lt, special)
  See +:h nvim_replace_termcodes()+
  @param [Boolean] from_part
  @param [Boolean] do_lt
  @param [Boolean] special
  @return [String]

@method command_output
  See +:h nvim_command_output()+
  @return [String]

@method eval
  See +:h nvim_eval()+
  @return [Object]

@method call_function(args)
  See +:h nvim_call_function()+
  @param [Array] args
  @return [Object]

@method strwidth
  See +:h nvim_strwidth()+
  @return [Integer]

@method list_runtime_paths
  See +:h nvim_list_runtime_paths()+
  @return [Array<String>]

@method set_current_dir
  See +:h nvim_set_current_dir()+
  @return [void]

@method get_current_line
  See +:h nvim_get_current_line()+
  @return [String]

@method set_current_line
  See +:h nvim_set_current_line()+
  @return [void]

@method del_current_line
  See +:h nvim_del_current_line()+
  @return [void]

@method get_var
  See +:h nvim_get_var()+
  @return [Object]

@method set_var(value)
  See +:h nvim_set_var()+
  @param [Object] value
  @return [void]

@method del_var
  See +:h nvim_del_var()+
  @return [void]

@method get_vvar
  See +:h nvim_get_vvar()+
  @return [Object]

@method get_option
  See +:h nvim_get_option()+
  @return [Object]

@method out_write
  See +:h nvim_out_write()+
  @return [void]

@method err_write
  See +:h nvim_err_write()+
  @return [void]

@method err_writeln
  See +:h nvim_err_writeln()+
  @return [void]

@method list_bufs
  See +:h nvim_list_bufs()+
  @return [Array<Buffer>]

@method get_current_buf
  See +:h nvim_get_current_buf()+
  @return [Buffer]

@method set_current_buf
  See +:h nvim_set_current_buf()+
  @return [void]

@method list_wins
  See +:h nvim_list_wins()+
  @return [Array<Window>]

@method get_current_win
  See +:h nvim_get_current_win()+
  @return [Window]

@method set_current_win
  See +:h nvim_set_current_win()+
  @return [void]

@method list_tabpages
  See +:h nvim_list_tabpages()+
  @return [Array<Tabpage>]

@method get_current_tabpage
  See +:h nvim_get_current_tabpage()+
  @return [Tabpage]

@method set_current_tabpage
  See +:h nvim_set_current_tabpage()+
  @return [void]

@method subscribe
  See +:h nvim_subscribe()+
  @return [void]

@method unsubscribe
  See +:h nvim_unsubscribe()+
  @return [void]

@method get_color_by_name
  See +:h nvim_get_color_by_name()+
  @return [Integer]

@method get_color_map
  See +:h nvim_get_color_map()+
  @return [Hash]

@method get_mode
  See +:h nvim_get_mode()+
  @return [Hash]

@method get_api_info
  See +:h nvim_get_api_info()+
  @return [Array]

@method call_atomic
  See +:h nvim_call_atomic()+
  @return [Array]

=end
  end
end
