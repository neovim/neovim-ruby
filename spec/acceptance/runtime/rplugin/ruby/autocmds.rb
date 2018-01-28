Neovim.plugin do |plug|
  plug.autocmd(:BufEnter, pattern: "*.rb", sync: true) do |nvim|
    nvim.get_current_buf.set_var("rplugin_autocmd_BufEnter", true)
  end

  plug.autocmd(:BufEnter, pattern: "*.c", eval: "g:to_eval", sync: true) do |nvim, to_eval|
    nvim.set_var("rplugin_autocmd_BufEnter_eval", to_eval.merge(b: 43))
  end

  plug.autocmd(:BufEnter, pattern: "*.async") do |nvim, to_eval|
    nvim.set_var("rplugin_autocmd_BufEnter_async", true)
  end
end
