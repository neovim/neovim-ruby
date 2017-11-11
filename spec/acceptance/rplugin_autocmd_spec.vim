Before (Generate rplugin manifest):
  silent UpdateRemotePlugins

Execute (Trigger event for matching patterns):
  silent split file.rb
  sleep 50m
  AssertEqual v:true, b:rplugin_autocmd_BufEnter

Execute (Don't trigger event for non-matching patterns):
  silent split file.py
  sleep 50m
  AssertEqual 0, exists("b:rplugin_autocmd_BufEnter")

Execute (Trigger event with eval):
  let g:to_eval = {'a': 42}
  silent split file.c
  sleep 50m
  AssertEqual {'a': 42, 'b': 43}, g:rplugin_autocmd_BufEnter_eval
