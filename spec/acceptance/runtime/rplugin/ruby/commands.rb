Neovim.plugin do |plug|
  plug.command(:RPluginCommandNargs0, sync: true) do |nvim|
    nvim.set_var("rplugin_command_nargs_0", true)
  end

  plug.command(:RPluginCommandNargs1, nargs: 1, sync: true) do |nvim, arg|
    nvim.set_var("rplugin_command_nargs_1", arg)
  end

  plug.command(:RPluginCommandNargsN, nargs: "*", sync: true) do |nvim, *args|
    nvim.set_var("rplugin_command_nargs_n", args)
  end

  plug.command(:RPluginCommandNargsQ, nargs: "?", sync: true) do |nvim, arg|
    nvim.set_var("rplugin_command_nargs_q", arg)
  end

  plug.command(:RPluginCommandNargsP, nargs: "+", sync: true) do |nvim, *args|
    nvim.set_var("rplugin_command_nargs_p", args)
  end

  plug.command(:RPluginCommandRange, range: true, sync: true) do |nvim, *range|
    nvim.set_var("rplugin_command_range", range)
  end

  plug.command(:RPluginCommandRangeP, range: "%", sync: true) do |nvim, *range|
    nvim.set_var("rplugin_command_range_p", range)
  end

  plug.command(:RPluginCommandRangeN, range: 1, sync: true) do |nvim, *range|
    nvim.set_var("rplugin_command_range_n", range)
  end

  plug.command(:RPluginCommandCountN, count: 1, sync: true) do |nvim, *count|
    nvim.set_var("rplugin_command_count_n", count)
  end

  plug.command(:RPluginCommandBang, bang: true, sync: true) do |nvim, bang|
    nvim.set_var("rplugin_command_bang", bang)
  end

  plug.command(:RPluginCommandRegister, register: true, sync: true) do |nvim, reg|
    nvim.set_var("rplugin_command_register", reg)
  end

  plug.command(:RPluginCommandCompletion, complete: "buffer", nargs: 1, sync: true) do |nvim, arg|
    attrs = nvim.command_output("silent command RPluginCommandCompletion")
    compl = attrs.split($/).last.split[2]
    nvim.set_var("rplugin_command_completion", [compl, arg])
  end

  plug.command(:RPluginCommandEval, eval: "g:to_eval", sync: true) do |nvim, to_eval|
    nvim.set_var("rplugin_command_eval", to_eval.merge(b: 43))
    to_eval.merge(b: 43)
  end

  plug.command(:RPluginCommandAsync) do |nvim|
    nvim.set_var("rplugin_command_async", true)
  end

  plug.command(:RPluginCommandRecursive, nargs: 1, sync: true) do |nvim, n|
    if Integer(n) >= 10
      nvim.set_var("rplugin_command_recursive", n)
    else
      nvim.command("RPluginCommandRecursive #{n.succ}")
    end
  end
end
