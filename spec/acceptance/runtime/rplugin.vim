" python3 plugins


" ruby plugins
call remote#host#RegisterPlugin('ruby', './runtime/rplugin/ruby/autocmds.rb', [
      \ {'sync': v:false, 'name': 'BufEnter', 'type': 'autocmd', 'opts': {'pattern': '*.rb'}},
      \ {'sync': v:false, 'name': 'BufEnter', 'type': 'autocmd', 'opts': {'pattern': '*.c', 'eval': 'g:to_eval'}},
     \ ])
call remote#host#RegisterPlugin('ruby', './runtime/rplugin/ruby/commands.rb', [
      \ {'sync': v:false, 'name': 'RPluginCommandNargs0', 'type': 'command', 'opts': {}},
      \ {'sync': v:false, 'name': 'RPluginCommandNargs1', 'type': 'command', 'opts': {'nargs': 1}},
      \ {'sync': v:false, 'name': 'RPluginCommandNargsN', 'type': 'command', 'opts': {'nargs': '*'}},
      \ {'sync': v:false, 'name': 'RPluginCommandNargsQ', 'type': 'command', 'opts': {'nargs': '?'}},
      \ {'sync': v:false, 'name': 'RPluginCommandNargsP', 'type': 'command', 'opts': {'nargs': '+'}},
      \ {'sync': v:false, 'name': 'RPluginCommandRange', 'type': 'command', 'opts': {'range': ''}},
      \ {'sync': v:false, 'name': 'RPluginCommandRangeP', 'type': 'command', 'opts': {'range': '%'}},
      \ {'sync': v:false, 'name': 'RPluginCommandRangeN', 'type': 'command', 'opts': {'range': '1'}},
      \ {'sync': v:false, 'name': 'RPluginCommandCountN', 'type': 'command', 'opts': {'count': 1}},
      \ {'sync': v:false, 'name': 'RPluginCommandBang', 'type': 'command', 'opts': {'bang': ''}},
      \ {'sync': v:false, 'name': 'RPluginCommandRegister', 'type': 'command', 'opts': {'register': ''}},
      \ {'sync': v:false, 'name': 'RPluginCommandCompletion', 'type': 'command', 'opts': {'complete': 'buffer'}},
      \ {'sync': v:false, 'name': 'RPluginCommandEval', 'type': 'command', 'opts': {'eval': 'g:to_eval'}},
      \ {'sync': v:true, 'name': 'RPluginCommandSync', 'type': 'command', 'opts': {}},
      \ {'sync': v:true, 'name': 'RPluginCommandRecursive', 'type': 'command', 'opts': {'nargs': 1}},
     \ ])
call remote#host#RegisterPlugin('ruby', './runtime/rplugin/ruby/functions.rb', [
      \ {'sync': v:false, 'name': 'RPluginFunctionArgs', 'type': 'function', 'opts': {}},
      \ {'sync': v:false, 'name': 'RPluginFunctionRange', 'type': 'function', 'opts': {'range': ''}},
      \ {'sync': v:false, 'name': 'RPluginFunctionEval', 'type': 'function', 'opts': {'eval': 'g:to_eval'}},
      \ {'sync': v:true, 'name': 'RPluginFunctionSync', 'type': 'function', 'opts': {}},
      \ {'sync': v:true, 'name': 'RPluginFunctionRecursive', 'type': 'function', 'opts': {'nargs': 1}},
     \ ])


" python plugins


