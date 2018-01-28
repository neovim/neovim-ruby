Neovim.plugin do |plug|
  plug.function(:RPluginFunctionArgs, sync: true) do |nvim, *args|
    args
  end

  plug.function(:RPluginFunctionRange, range: true, sync: true) do |nvim, start, stop|
    nvim.set_var("rplugin_function_range", [start, stop])
  end

  plug.function(:RPluginFunctionEval, eval: "g:to_eval", sync: true) do |nvim, to_eval|
    to_eval.merge(b: 43)
  end

  plug.function(:RPluginFunctionAsync) do |nvim|
    nvim.set_var("rplugin_function_async", true)
  end

  plug.function(:RPluginFunctionRecursive, sync: true, nargs: 1) do |nvim, n|
    if n >= 10
      n
    else
      nvim.evaluate("RPluginFunctionRecursive(#{n + 1})")
    end
  end
end
