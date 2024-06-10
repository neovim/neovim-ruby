require "neovim"

Neovim.start_remote do |mod|
  mod.register_handler("rb_set_var") do |nvim, name, val|
    nvim.set_var(name, val.to_s)
  end

  mod.register_handler("rb_will_raise") do |nvim|
    raise "oops"
  end
end
