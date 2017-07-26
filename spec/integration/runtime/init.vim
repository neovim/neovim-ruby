let s:lib_path = getcwd() . "/../../lib/"
let s:bin_path = getcwd() . "/../../bin/neovim-ruby-host"
let g:ruby_host_prog = printf("ruby -I %s %s", s:lib_path, s:bin_path)

set rtp=./runtime,./runtime/vader.vim,$VIMRUNTIME

ruby require "rspec"

function! RunSuite() abort
  ruby $output = ENV["RSPEC_OUTPUT_FILE"]
  ruby $result = RSpec::Core::Runner.run([], $output, $output)
  ruby Vim.command($result == 0 ? "qa!" : "cq!")
endfunction
