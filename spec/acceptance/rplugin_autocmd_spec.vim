let s:suite = themis#suite("Remote plugin autocmd")
let s:expect = themis#helper("expect")

function! s:suite.has_nvim() abort
  call s:expect(has("nvim")).to_equal(1)
endfunction

function! s:suite.triggers_for_matched_pattern() abort
  silent split file.rb
  call s:expect(b:rplugin_autocmd_BufEnter).to_equal(v:true)
endfunction

function! s:suite.doesnt_trigger_for_unmatched_pattern() abort
  silent split file.py
  call s:expect(exists('b:rplugin_autocmd_BufEnter')).to_equal(0)
endfunction

function! s:suite.supports_eval() abort
  let g:to_eval = {'a': 42}
  silent split file.c
  call s:expect(g:rplugin_autocmd_BufEnter_eval).to_equal({'a': 42, 'b': 43})
endfunction

function! s:suite.supports_async() abort
  silent split file.async
  sleep 50m
  call s:expect(g:rplugin_autocmd_BufEnter_async).to_equal(v:true)
endfunction
