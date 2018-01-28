let s:lib_path = getcwd() . "/lib"
let s:bin_path = getcwd() . "/bin/neovim-ruby-host"
let g:acceptance_rtp = getcwd() . "/spec/acceptance/runtime"
let g:ruby_host_prog = printf("ruby -I %s %s", s:lib_path, s:bin_path)

ruby require "rspec/expectations"
ruby include ::RSpec::Matchers.dup

set rtp=./spec/acceptance/runtime,$VIMRUNTIME
