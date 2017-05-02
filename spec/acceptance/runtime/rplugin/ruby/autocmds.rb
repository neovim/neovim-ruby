Neovim.plugin do |plug|
  plug.autocmd(:BufEnter, :pattern => "*.rb") do |nvim|
    nvim.get_current_buffer.set_var("rplugin_autocmd_BufEnter", true)
  end

  plug.autocmd(:BufEnter, :pattern => "*.c", :eval => "g:to_eval") do |nvim, to_eval|
    nvim.set_var("rplugin_autocmd_BufEnter_eval", to_eval)
  end
end
