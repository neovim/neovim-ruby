Given:
  one
  two

Execute (Update remote plugins):
  silent UpdateRemotePlugins

Then (Call rplugin function):
  AssertEqual 3, PlugAdd(1, 2)

Execute (Call async rplugin command):
  PlugSetFoo bar
  sleep 100m

Then:
  AssertEqual "bar", g:PlugFoo

Execute (Trigger async rplugin autocmd):
  silent edit foo.rb
  sleep 100m

Then:
  Assert g:PlugInRuby
