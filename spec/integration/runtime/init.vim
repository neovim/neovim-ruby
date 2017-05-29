set rtp=./runtime,./runtime/vader.vim,$VIMRUNTIME

ruby require "rspec"

function! RunSuite() abort
  ruby $output = ENV["RSPEC_OUTPUT_FILE"]
  ruby $result = RSpec::Core::Runner.run([], $output, $output)
  ruby Vim.command($result == 0 ? "qa!" : "cq!")
endfunction
