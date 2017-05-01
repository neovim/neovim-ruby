Before (Generate rplugin manifest):
  silent UpdateRemotePlugins

Given:
  one
  two

Execute (Call rplugin function):
  AssertEqual 3, PlugAdd(1, 2)

Execute (Call async rplugin command):
  PlugSetFoo bar
  sleep 50m

Then:
  AssertEqual "bar", g:PlugFoo

Execute (Trigger async rplugin autocmd):
  silent edit foo.rb
  sleep 50m

Then:
  Assert g:PlugInRuby
