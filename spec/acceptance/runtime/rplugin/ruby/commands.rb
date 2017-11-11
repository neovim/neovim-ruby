Neovim.plugin do |plug|
  plug.command(:RPluginCommandNargs0) do |nvim|
    nvim.set_var("rplugin_command_nargs_0", true)
  end

  plug.command(:RPluginCommandNargs1, :nargs => 1) do |nvim, arg|
    nvim.set_var("rplugin_command_nargs_1", arg)
  end

  plug.command(:RPluginCommandNargsN, :nargs => "*") do |nvim, *args|
    nvim.set_var("rplugin_command_nargs_n", args)
  end

  plug.command(:RPluginCommandNargsQ, :nargs => "?") do |nvim, arg|
    nvim.set_var("rplugin_command_nargs_q", arg)
  end

  plug.command(:RPluginCommandNargsP, :nargs => "+") do |nvim, *args|
    nvim.set_var("rplugin_command_nargs_p", args)
  end

  plug.command(:RPluginCommandRange, :range => true) do |nvim, *range|
    nvim.set_var("rplugin_command_range", range)
  end

  plug.command(:RPluginCommandRangeP, :range => "%") do |nvim, *range|
    nvim.set_var("rplugin_command_range_p", range)
  end

  plug.command(:RPluginCommandRangeN, :range => 1) do |nvim, *range|
    nvim.set_var("rplugin_command_range_n", range)
  end

  plug.command(:RPluginCommandCountN, :count => 1) do |nvim, *count|
    nvim.set_var("rplugin_command_count_n", count)
  end

  plug.command(:RPluginCommandBang, :bang => true) do |nvim, bang|
    nvim.set_var("rplugin_command_bang", bang)
  end

  plug.command(:RPluginCommandRegister, :register => true) do |nvim, reg|
    nvim.set_var("rplugin_command_register", reg)
  end

  plug.command(:RPluginCommandCompletion, :complete => "buffer") do |nvim|
    attrs = nvim.command_output("silent command RPluginCommandCompletion")
    compl = attrs.split("\n").last.split[2]
    nvim.set_var("rplugin_command_completion", compl)
  end

  plug.command(:RPluginCommandEval, :eval => "g:to_eval") do |nvim, to_eval|
    nvim.set_var("rplugin_command_eval", to_eval.merge(:b => 43))
  end

  plug.command(:RPluginCommandSync, :sync => true) do |nvim|
    nvim.set_var("rplugin_command_sync", true)
  end

  plug.command(:RPluginCommandRecursive, :sync => true, :nargs => 1) do |nvim, n|
    if Integer(n) >= 10
      nvim.set_var("rplugin_command_recursive", n)
    else
      nvim.command("RPluginCommandRecursive #{n.succ}")
    end
  end
end
