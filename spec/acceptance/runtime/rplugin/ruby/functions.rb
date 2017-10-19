Neovim.plugin do |plug|
  plug.function(:RPluginFunctionArgs) do |nvim, *args|
    nvim.set_var("rplugin_function_args", args)
  end

  plug.function(:RPluginFunctionRange, :range => true) do |nvim, *range|
    nvim.set_var("rplugin_function_range", range)
  end

  plug.function(:RPluginFunctionEval, :eval => "g:to_eval") do |nvim, to_eval|
    nvim.set_var("rplugin_function_eval", to_eval)
  end

  plug.function(:RPluginFunctionSync, :sync => true) do |nvim|
    true
  end

  plug.function(:RPluginFunctionRecursive, :sync => true, :nargs => 1) do |nvim, n|
    if n >= 10
      n
    else
      nvim.evaluate("RPluginFunctionRecursive(#{n + 1})")
    end
  end
end
