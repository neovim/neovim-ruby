Given:
  one
  two

Execute (Update remote plugins):
  silent UpdateRemotePlugins

Execute (Call rplugin command):
  PlugSetFoo bar
  sleep 100m
  AssertEqual "bar", g:PlugFoo

Execute (Call rplugin function):
  AssertEqual 3, PlugAdd(1, 2)

Execute (Trigger rplugin autocmd):
  silent edit foo.rb
  sleep 100m
  AssertEqual 1, g:PlugInRuby
