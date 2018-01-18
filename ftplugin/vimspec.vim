" Vimspec filetype plugin
" Version: 1.5.4
" Author : thinca <thinca+vim@gmail.com>
" License: zlib License

if exists('b:did_ftplugin')
  finish
endif

runtime! ftplugin/vim.vim ftplugin/vim_*.vim ftplugin/vim/*.vim

let b:did_ftplugin = 1

if exists('b:match_words')
  let b:match_words .= ','
else
  let b:match_words = ''
endif
let b:match_words .= '\%(^\s*\)\@<=\<\%([Dd]escribe\|[Cc]ontext\|[Ii]t\|[Bb]efore\|[Aa]fter\)\>:\<[Ee]nd\>'

if exists('b:undo_ftplugin')
  let b:undo_ftplugin = ' | ' . b:undo_ftplugin
else
  let b:undo_ftplugin = ''
endif
let b:undo_ftplugin = 'unlet! b:match_words' . b:undo_ftplugin
