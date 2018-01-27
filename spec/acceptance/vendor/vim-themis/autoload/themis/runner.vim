" themis: Test runner
" Version: 1.5.4
" Author : thinca <thinca+vim@gmail.com>
" License: zlib License

let s:save_cpo = &cpo
set cpo&vim

let s:Runner = {}

function! s:Runner.init() abort
  let self._emitter = themis#emitter#new()
  let self._supporters = {}
  let self._styles = {}
  for style_name in themis#module#list('style')
    let self._styles[style_name] = themis#module#style(style_name)
  endfor

  let style_event = deepcopy(s:style_event)
  let style_event.runner = self
  call self.add_event(style_event)
endfunction

function! s:Runner.start(paths, options) abort
  try
    let save_runtimepath = &runtimepath

    let paths = type(a:paths) == type([]) ? a:paths : [a:paths]

    call s:load_themisrc(paths)

    let options = themis#option#merge(themis#option(), a:options)

    call s:load_plugins(options.runtimepath)

    let reporter = themis#module#reporter(options.reporter)
    call self.add_event(reporter)

    let files = self.get_target_files(paths, options)
    let bundle = self.load_bundle_from_files(files)
    if !themis#bundle#is_bundle(bundle)
      return 1
    endif

    let target_pattern = join(a:options.target, '\m\|')
    call bundle.select_tests_recursive(target_pattern)
    return self.run(bundle)
  finally
    let &runtimepath = save_runtimepath
  endtry
endfunction

function! s:Runner.get_target_files(paths, options) abort
  let files = s:paths2files(a:paths, a:options.recursive)

  let exclude_options = filter(copy(a:options.exclude), '!empty(v:val)')
  let exclude_pattern = join(exclude_options, '\|\m')
  if !empty(exclude_pattern)
    call filter(files, 'v:val !~# exclude_pattern')
  endif
  return files
endfunction

function! s:Runner.load_bundle_from_files(files) abort
  let files_with_styles = {}
  for file in a:files
    let style = s:can_handle(values(self._styles), file)
    if style !=# ''
      let files_with_styles[file] = style
    endif
  endfor

  if empty(files_with_styles)
    throw 'themis: Target file not found.'
  endif

  let bundle = themis#bundle#new()
  try
    call self.load_scripts(files_with_styles, bundle)
    call self.emit('script_loaded', self)
  catch
    call self.on_error('script loading', v:exception, v:throwpoint)
    return {}
  endtry
  return bundle
endfunction

function! s:Runner.load_scripts(files_with_styles, target_bundle) abort
  for [filename, style_name] in items(a:files_with_styles)
    if !filereadable(filename)
      throw printf('themis: Target file was not found: %s', filename)
    endif
    let style = self._styles[style_name]
    let base = themis#bundle#new('', a:target_bundle)
    let base.style = style
    call themis#_set_base_bundle(base)
    call style.load_script(filename, base)
    call themis#_unset_base_bundle()
  endfor
endfunction

function! s:Runner.run(bundle) abort
  let stats = self.supporter('stats')
  call self.supporter('builtin_assert')
  call self.emit('init', self, a:bundle)
  let error_count = 0
  try
    call self.run_all(a:bundle)
    let error_count = stats.fail()
  catch
    call self.on_error('running', v:exception, v:throwpoint)
    let error_count = 1
  finally
    call self.emit('finish', self)
  endtry
  return error_count
endfunction

function! s:Runner.run_all(bundle) abort
  call self.emit('start', self)
  call self.run_bundle(a:bundle)
  call self.emit('end', self)
endfunction

function! s:Runner.run_bundle(bundle) abort
  if a:bundle.is_empty()
    return
  endif
  call self.emit('before_suite', a:bundle)
  call self.run_suite(a:bundle, a:bundle.get_test_entries())
  for child in a:bundle.children
    call self.run_bundle(child)
  endfor
  call self.emit('after_suite', a:bundle)
endfunction

function! s:Runner.run_suite(bundle, test_entries) abort
  for entry in a:test_entries
    call self.emit('start_test', a:bundle, entry)
    call self.run_test(a:bundle, entry)
  endfor
endfunction

function! s:Runner.run_test(bundle, test_entry) abort
  let report = themis#report#new(a:bundle, a:test_entry)
  try
    call self.emit_before_test(a:bundle, a:test_entry)
    let start_time = reltime()
    call a:bundle.run_test(a:test_entry)
    let end_time = reltime(start_time)
    let report.result = 'pass'
    let report.time = str2float(reltimestr(end_time))
  catch
    call report.add_exception(v:exception, v:throwpoint)
  finally
    call self.emit_after_test(a:bundle, a:test_entry, report)
    call self.emit('end_test', report)
    call self.emit(report.result, report)
  endtry
endfunction

" FIXME: a:bundle may not have a:test_entry.
" Should I pass the original bundle?
function! s:Runner.emit_before_test(bundle, test_entry) abort
  if has_key(a:bundle, 'parent')
    call self.emit_before_test(a:bundle.parent, a:test_entry)
  endif
  call self.emit('before_test', a:bundle, a:test_entry)
endfunction

function! s:Runner.emit_after_test(bundle, test_entry, report) abort
  try
    call self.emit('after_test', a:bundle, a:test_entry)
  catch
    call a:report.add_exception(v:exception, v:throwpoint)
  endtry
  if has_key(a:bundle, 'parent')
    call self.emit_after_test(a:bundle.parent, a:test_entry, a:report)
  endif
endfunction

function! s:Runner.supporter(name) abort
  if !has_key(self._supporters, a:name)
    let self._supporters[a:name] = themis#module#supporter(a:name, self)
  endif
  return self._supporters[a:name]
endfunction

function! s:Runner.add_event(listener) abort
  call self._emitter.add_listener(a:listener)
endfunction

function! s:Runner.emit(name, ...) abort
  call call(self._emitter.emit, [a:name] + a:000, self._emitter)
endfunction

function! s:Runner.on_error(phase, exception, throwpoint) abort
  let phase = self._emitter.emitting()
  if phase ==# ''
    let phase = a:phase
  endif
  if a:exception =~# '^themis:'
    let info = {
    \   'exception': matchstr(a:exception, '\C^themis:\s*\zs.*'),
    \ }
  else
    let info = {
    \   'exception': a:exception,
    \   'stacktrace': themis#util#callstack(a:throwpoint, -1),
    \ }
  endif
  call self.emit('error', a:phase, info)
endfunction

let s:style_event = {}
function! s:style_event._(event, args) abort
  if themis#bundle#is_bundle(get(a:args, 0))
    let bundle = a:args[0]
    let style = bundle.get_style()
    if has_key(style, 'event')
      call themis#emitter#fire(style.event, a:event, a:args)
    endif
  else
    for style in values(self.runner._styles)
      if has_key(style, 'event')
        call themis#emitter#fire(style.event, a:event, a:args)
      endif
    endfor
  endif
endfunction

function! s:append_rtp(path) abort
  let appended = []
  if isdirectory(a:path)
    let path = substitute(a:path, '\\\+', '/', 'g')
    let path = substitute(path, '/$', '', 'g')
    let &runtimepath = escape(path, ',') . ',' . &runtimepath
    let appended += [path]
    let after = path . '/after'
    if isdirectory(after)
      let &runtimepath .= ',' . escape(after, ',')
      let appended += [after]
    endif
  endif
  return appended
endfunction

function! s:load_themisrc(paths) abort
  let themisrcs = themis#util#find_files(a:paths, '.themisrc')
  for themisrc in themisrcs
    execute 'source' fnameescape(themisrc)
  endfor
endfunction

function! s:load_plugins(runtimepaths) abort
  let appended = [getcwd()]
  if !empty(a:runtimepaths)
    for rtp in a:runtimepaths
      let appended += s:append_rtp(rtp)
    endfor
  endif

  let plugins = globpath(join(appended, ','), 'plugin/**/*.vim', 1)
  for plugin in split(plugins, "\n")
    execute 'source' fnameescape(plugin)
  endfor
endfunction

function! s:paths2files(paths, recursive) abort
  let files = []
  let target_pattern = a:recursive ? '**/*' : '*'
  for path in a:paths
    if isdirectory(path)
      let files += split(globpath(path, target_pattern, 1), "\n")
    else
      let files += [path]
    endif
  endfor
  let mods =  ':p:gs?\\?/?'
  return filter(map(files, 'fnamemodify(v:val, mods)'), '!isdirectory(v:val)')
endfunction

function! s:can_handle(styles, file) abort
  for style in a:styles
    if style.can_handle(a:file)
      return style.name
    endif
  endfor
  return ''
endfunction

function! themis#runner#new() abort
  let runner = deepcopy(s:Runner)
  call runner.init()
  return runner
endfunction

call themis#func_alias({'themis/Runner': s:Runner})


let &cpo = s:save_cpo
unlet s:save_cpo
