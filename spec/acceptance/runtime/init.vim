let s:lib_path = getcwd() . "/lib"
let s:exe_path = getcwd() . "/exe/neovim-ruby-host"
let g:acceptance_rtp = getcwd() . "/spec/acceptance/runtime"

if has("win32") || has("win64")
  let g:ruby_host_prog = getcwd() . "/script/host_wrapper.bat"
else
  let g:ruby_host_prog = getcwd() . "/script/host_wrapper.sh"
endif

ruby require "rspec/expectations"
ruby include ::RSpec::Matchers.dup

set rtp=./spec/acceptance/runtime,$VIMRUNTIME
