" Syntax file for vimspec
" Version: 1.5.4
" Author : thinca <thinca+vim@gmail.com>
" License: zlib License

if exists('b:current_syntax')
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

runtime! syntax/vim.vim

syntax keyword vimspecCommand describe Describe skipwhite nextgroup=vimspecDescription
syntax keyword vimspecCommand context Context skipwhite nextgroup=vimspecDescription
syntax keyword vimspecCommand before Before skipwhite nextgroup=vimspecHook
syntax keyword vimspecCommand after After skipwhite nextgroup=vimspecHook
syntax keyword vimspecCommand end End
syntax keyword vimspecCommand it It skipwhite nextgroup=vimspecExample

syntax match vimspecDescription /\S.*$/ contained
syntax match vimspecExample /\S.*$/ contained
syntax match vimspecHook /\<\%(all\|each\)\>/ contained


highlight default link vimspecCommand     vimCommand
highlight default link vimspecDescription vimString
highlight default link vimspecExample     vimString
highlight default link vimspecHook        Type


let b:current_syntax = 'vimspec'

let &cpo = s:cpo_save
unlet s:cpo_save
