Neovim.plugin do |plug|
  plug.command(:PlugSetFoo, :nargs => 1) do |nvim, str|
    nvim.command("let g:PlugFoo = '#{str}'")
  end

  plug.function(:PlugAdd, :args => 2, :sync => true) do |nvim, x, y|
    x + y
  end

  plug.autocmd(:BufEnter, :pattern => "*.rb") do |nvim|
    nvim.command("let g:PlugInRuby = 1")
  end
end
