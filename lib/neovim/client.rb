require "neovim/api"
require "neovim/current"
require "neovim/session"
require "set"

module Neovim
  # Client to a running +nvim+ instance. The interface is generated at
  # runtime via the +nvim_get_api_info+ RPC call. Some methods return
  # +RemoteObject+ subclasses (i.e. +Buffer+, +Window+, or +Tabpage+),
  # which similarly have dynamically generated interfaces.
  #
  # The methods documented here were generated using NVIM v0.9.1
  #
  # @see Buffer
  # @see Window
  # @see Tabpage
  class Client
    attr_reader :session, :api

    def self.from_event_loop(event_loop, session=Session.new(event_loop))
      api = API.new(session.request(:nvim_get_api_info))
      event_loop.register_types(api, session)

      new(session, api)
    end

    def initialize(session, api)
      @session = session
      @api = api
    end

    def channel_id
      @api.channel_id
    end

    # Intercept method calls and delegate to appropriate RPC methods.
    def method_missing(method_name, *args)
      if (func = @api.function_for_object_method(self, method_name))
        func.call(@session, *args)
      else
        super
      end
    end

    # Extend +respond_to_missing?+ to support RPC methods.
    def respond_to_missing?(method_name, *)
      super || rpc_methods.include?(method_name.to_sym)
    end

    # Extend +methods+ to include RPC methods.
    def methods(*args)
      super | rpc_methods.to_a
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
      @rpc_methods ||=
        @api.functions_for_object(self).map(&:method_name).to_set
    end

    public

# The following methods are dynamically generated.
=begin
@method get_autocmds(opts)
  See +:h nvim_get_autocmds()+
  @param [Hash] opts
  @return [Array]

@method create_autocmd(event, opts)
  See +:h nvim_create_autocmd()+
  @param [Object] event
  @param [Hash] opts
  @return [Integer]

@method del_autocmd(id)
  See +:h nvim_del_autocmd()+
  @param [Integer] id
  @return [void]

@method clear_autocmds(opts)
  See +:h nvim_clear_autocmds()+
  @param [Hash] opts
  @return [void]

@method create_augroup(name, opts)
  See +:h nvim_create_augroup()+
  @param [String] name
  @param [Hash] opts
  @return [Integer]

@method del_augroup_by_id(id)
  See +:h nvim_del_augroup_by_id()+
  @param [Integer] id
  @return [void]

@method del_augroup_by_name(name)
  See +:h nvim_del_augroup_by_name()+
  @param [String] name
  @return [void]

@method exec_autocmds(event, opts)
  See +:h nvim_exec_autocmds()+
  @param [Object] event
  @param [Hash] opts
  @return [void]

@method parse_cmd(str, opts)
  See +:h nvim_parse_cmd()+
  @param [String] str
  @param [Hash] opts
  @return [Hash]

@method cmd(cmd, opts)
  See +:h nvim_cmd()+
  @param [Hash] cmd
  @param [Hash] opts
  @return [String]

@method create_user_command(name, command, opts)
  See +:h nvim_create_user_command()+
  @param [String] name
  @param [Object] command
  @param [Hash] opts
  @return [void]

@method del_user_command(name)
  See +:h nvim_del_user_command()+
  @param [String] name
  @return [void]

@method get_commands(opts)
  See +:h nvim_get_commands()+
  @param [Hash] opts
  @return [Hash]

@method exec(src, output)
  See +:h nvim_exec()+
  @param [String] src
  @param [Boolean] output
  @return [String]

@method command_output(command)
  See +:h nvim_command_output()+
  @param [String] command
  @return [String]

@method execute_lua(code, args)
  See +:h nvim_execute_lua()+
  @param [String] code
  @param [Array] args
  @return [Object]

@method get_hl_by_id(hl_id, rgb)
  See +:h nvim_get_hl_by_id()+
  @param [Integer] hl_id
  @param [Boolean] rgb
  @return [Hash]

@method get_hl_by_name(name, rgb)
  See +:h nvim_get_hl_by_name()+
  @param [String] name
  @param [Boolean] rgb
  @return [Hash]

@method get_option_info(name)
  See +:h nvim_get_option_info()+
  @param [String] name
  @return [Hash]

@method create_namespace(name)
  See +:h nvim_create_namespace()+
  @param [String] name
  @return [Integer]

@method get_namespaces
  See +:h nvim_get_namespaces()+
  @return [Hash]

@method set_decoration_provider(ns_id, opts)
  See +:h nvim_set_decoration_provider()+
  @param [Integer] ns_id
  @param [Hash] opts
  @return [void]

@method get_option_value(name, opts)
  See +:h nvim_get_option_value()+
  @param [String] name
  @param [Hash] opts
  @return [Object]

@method set_option_value(name, value, opts)
  See +:h nvim_set_option_value()+
  @param [String] name
  @param [Object] value
  @param [Hash] opts
  @return [void]

@method get_all_options_info
  See +:h nvim_get_all_options_info()+
  @return [Hash]

@method get_option_info2(name, opts)
  See +:h nvim_get_option_info2()+
  @param [String] name
  @param [Hash] opts
  @return [Hash]

@method get_option(name)
  See +:h nvim_get_option()+
  @param [String] name
  @return [Object]

@method ui_attach(width, height, options)
  See +:h nvim_ui_attach()+
  @param [Integer] width
  @param [Integer] height
  @param [Hash] options
  @return [void]

@method ui_set_focus(gained)
  See +:h nvim_ui_set_focus()+
  @param [Boolean] gained
  @return [void]

@method ui_detach
  See +:h nvim_ui_detach()+
  @return [void]

@method ui_try_resize(width, height)
  See +:h nvim_ui_try_resize()+
  @param [Integer] width
  @param [Integer] height
  @return [void]

@method ui_set_option(name, value)
  See +:h nvim_ui_set_option()+
  @param [String] name
  @param [Object] value
  @return [void]

@method ui_try_resize_grid(grid, width, height)
  See +:h nvim_ui_try_resize_grid()+
  @param [Integer] grid
  @param [Integer] width
  @param [Integer] height
  @return [void]

@method ui_pum_set_height(height)
  See +:h nvim_ui_pum_set_height()+
  @param [Integer] height
  @return [void]

@method ui_pum_set_bounds(width, height, row, col)
  See +:h nvim_ui_pum_set_bounds()+
  @param [Float] width
  @param [Float] height
  @param [Float] row
  @param [Float] col
  @return [void]

@method get_hl_id_by_name(name)
  See +:h nvim_get_hl_id_by_name()+
  @param [String] name
  @return [Integer]

@method get_hl(ns_id, opts)
  See +:h nvim_get_hl()+
  @param [Integer] ns_id
  @param [Hash] opts
  @return [Hash]

@method set_hl(ns_id, name, val)
  See +:h nvim_set_hl()+
  @param [Integer] ns_id
  @param [String] name
  @param [Hash] val
  @return [void]

@method set_hl_ns(ns_id)
  See +:h nvim_set_hl_ns()+
  @param [Integer] ns_id
  @return [void]

@method set_hl_ns_fast(ns_id)
  See +:h nvim_set_hl_ns_fast()+
  @param [Integer] ns_id
  @return [void]

@method feedkeys(keys, mode, escape_ks)
  See +:h nvim_feedkeys()+
  @param [String] keys
  @param [String] mode
  @param [Boolean] escape_ks
  @return [void]

@method input(keys)
  See +:h nvim_input()+
  @param [String] keys
  @return [Integer]

@method input_mouse(button, action, modifier, grid, row, col)
  See +:h nvim_input_mouse()+
  @param [String] button
  @param [String] action
  @param [String] modifier
  @param [Integer] grid
  @param [Integer] row
  @param [Integer] col
  @return [void]

@method replace_termcodes(str, from_part, do_lt, special)
  See +:h nvim_replace_termcodes()+
  @param [String] str
  @param [Boolean] from_part
  @param [Boolean] do_lt
  @param [Boolean] special
  @return [String]

@method exec_lua(code, args)
  See +:h nvim_exec_lua()+
  @param [String] code
  @param [Array] args
  @return [Object]

@method notify(msg, log_level, opts)
  See +:h nvim_notify()+
  @param [String] msg
  @param [Integer] log_level
  @param [Hash] opts
  @return [Object]

@method strwidth(text)
  See +:h nvim_strwidth()+
  @param [String] text
  @return [Integer]

@method list_runtime_paths
  See +:h nvim_list_runtime_paths()+
  @return [Array<String>]

@method get_runtime_file(name, all)
  See +:h nvim_get_runtime_file()+
  @param [String] name
  @param [Boolean] all
  @return [Array<String>]

@method set_current_dir(dir)
  See +:h nvim_set_current_dir()+
  @param [String] dir
  @return [void]

@method get_current_line
  See +:h nvim_get_current_line()+
  @return [String]

@method set_current_line(line)
  See +:h nvim_set_current_line()+
  @param [String] line
  @return [void]

@method del_current_line
  See +:h nvim_del_current_line()+
  @return [void]

@method get_var(name)
  See +:h nvim_get_var()+
  @param [String] name
  @return [Object]

@method set_var(name, value)
  See +:h nvim_set_var()+
  @param [String] name
  @param [Object] value
  @return [void]

@method del_var(name)
  See +:h nvim_del_var()+
  @param [String] name
  @return [void]

@method get_vvar(name)
  See +:h nvim_get_vvar()+
  @param [String] name
  @return [Object]

@method set_vvar(name, value)
  See +:h nvim_set_vvar()+
  @param [String] name
  @param [Object] value
  @return [void]

@method echo(chunks, history, opts)
  See +:h nvim_echo()+
  @param [Array] chunks
  @param [Boolean] history
  @param [Hash] opts
  @return [void]

@method out_write(str)
  See +:h nvim_out_write()+
  @param [String] str
  @return [void]

@method err_write(str)
  See +:h nvim_err_write()+
  @param [String] str
  @return [void]

@method err_writeln(str)
  See +:h nvim_err_writeln()+
  @param [String] str
  @return [void]

@method list_bufs
  See +:h nvim_list_bufs()+
  @return [Array<Buffer>]

@method get_current_buf
  See +:h nvim_get_current_buf()+
  @return [Buffer]

@method set_current_buf(buffer)
  See +:h nvim_set_current_buf()+
  @param [Buffer] buffer
  @return [void]

@method list_wins
  See +:h nvim_list_wins()+
  @return [Array<Window>]

@method get_current_win
  See +:h nvim_get_current_win()+
  @return [Window]

@method set_current_win(window)
  See +:h nvim_set_current_win()+
  @param [Window] window
  @return [void]

@method create_buf(listed, scratch)
  See +:h nvim_create_buf()+
  @param [Boolean] listed
  @param [Boolean] scratch
  @return [Buffer]

@method open_term(buffer, opts)
  See +:h nvim_open_term()+
  @param [Buffer] buffer
  @param [Hash] opts
  @return [Integer]

@method chan_send(chan, data)
  See +:h nvim_chan_send()+
  @param [Integer] chan
  @param [String] data
  @return [void]

@method list_tabpages
  See +:h nvim_list_tabpages()+
  @return [Array<Tabpage>]

@method get_current_tabpage
  See +:h nvim_get_current_tabpage()+
  @return [Tabpage]

@method set_current_tabpage(tabpage)
  See +:h nvim_set_current_tabpage()+
  @param [Tabpage] tabpage
  @return [void]

@method paste(data, crlf, phase)
  See +:h nvim_paste()+
  @param [String] data
  @param [Boolean] crlf
  @param [Integer] phase
  @return [Boolean]

@method put(lines, type, after, follow)
  See +:h nvim_put()+
  @param [Array<String>] lines
  @param [String] type
  @param [Boolean] after
  @param [Boolean] follow
  @return [void]

@method subscribe(event)
  See +:h nvim_subscribe()+
  @param [String] event
  @return [void]

@method unsubscribe(event)
  See +:h nvim_unsubscribe()+
  @param [String] event
  @return [void]

@method get_color_by_name(name)
  See +:h nvim_get_color_by_name()+
  @param [String] name
  @return [Integer]

@method get_color_map
  See +:h nvim_get_color_map()+
  @return [Hash]

@method get_context(opts)
  See +:h nvim_get_context()+
  @param [Hash] opts
  @return [Hash]

@method load_context(dict)
  See +:h nvim_load_context()+
  @param [Hash] dict
  @return [Object]

@method get_mode
  See +:h nvim_get_mode()+
  @return [Hash]

@method get_keymap(mode)
  See +:h nvim_get_keymap()+
  @param [String] mode
  @return [Array<Hash>]

@method set_keymap(mode, lhs, rhs, opts)
  See +:h nvim_set_keymap()+
  @param [String] mode
  @param [String] lhs
  @param [String] rhs
  @param [Hash] opts
  @return [void]

@method del_keymap(mode, lhs)
  See +:h nvim_del_keymap()+
  @param [String] mode
  @param [String] lhs
  @return [void]

@method get_api_info
  See +:h nvim_get_api_info()+
  @return [Array]

@method set_client_info(name, version, type, methods, attributes)
  See +:h nvim_set_client_info()+
  @param [String] name
  @param [Hash] version
  @param [String] type
  @param [Hash] methods
  @param [Hash] attributes
  @return [void]

@method get_chan_info(chan)
  See +:h nvim_get_chan_info()+
  @param [Integer] chan
  @return [Hash]

@method list_chans
  See +:h nvim_list_chans()+
  @return [Array]

@method call_atomic(calls)
  See +:h nvim_call_atomic()+
  @param [Array] calls
  @return [Array]

@method list_uis
  See +:h nvim_list_uis()+
  @return [Array]

@method get_proc_children(pid)
  See +:h nvim_get_proc_children()+
  @param [Integer] pid
  @return [Array]

@method get_proc(pid)
  See +:h nvim_get_proc()+
  @param [Integer] pid
  @return [Object]

@method select_popupmenu_item(item, insert, finish, opts)
  See +:h nvim_select_popupmenu_item()+
  @param [Integer] item
  @param [Boolean] insert
  @param [Boolean] finish
  @param [Hash] opts
  @return [void]

@method del_mark(name)
  See +:h nvim_del_mark()+
  @param [String] name
  @return [Boolean]

@method get_mark(name, opts)
  See +:h nvim_get_mark()+
  @param [String] name
  @param [Hash] opts
  @return [Array]

@method eval_statusline(str, opts)
  See +:h nvim_eval_statusline()+
  @param [String] str
  @param [Hash] opts
  @return [Hash]

@method exec2(src, opts)
  See +:h nvim_exec2()+
  @param [String] src
  @param [Hash] opts
  @return [Hash]

@method command(command)
  See +:h nvim_command()+
  @param [String] command
  @return [void]

@method eval(expr)
  See +:h nvim_eval()+
  @param [String] expr
  @return [Object]

@method call_function(fn, args)
  See +:h nvim_call_function()+
  @param [String] fn
  @param [Array] args
  @return [Object]

@method call_dict_function(dict, fn, args)
  See +:h nvim_call_dict_function()+
  @param [Object] dict
  @param [String] fn
  @param [Array] args
  @return [Object]

@method parse_expression(expr, flags, highlight)
  See +:h nvim_parse_expression()+
  @param [String] expr
  @param [String] flags
  @param [Boolean] highlight
  @return [Hash]

@method open_win(buffer, enter, config)
  See +:h nvim_open_win()+
  @param [Buffer] buffer
  @param [Boolean] enter
  @param [Hash] config
  @return [Window]

=end
  end
end
