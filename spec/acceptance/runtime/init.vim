let s:lib_path = fnamemodify(getcwd() . "/../../lib", ":p")
let s:bin_path = fnamemodify(getcwd() . "/../../bin/neovim-ruby-host", ":p")
let g:ruby_host_prog = printf("ruby -I %s %s", s:lib_path, s:bin_path)

ruby require "rspec/expectations"
ruby include ::RSpec::Matchers.dup

set rtp=./runtime,./runtime/vader.vim,$VIMRUNTIME
