let s:suite = themis#suite("Client info")
let s:expect = themis#helper("expect")

function! s:suite.before_each() abort
  call RPluginFunctionArgs(1, 2)

  let s:client_chans = map(
        \ filter(nvim_list_chans(), "has_key(v:val, 'client')"),
        \ "v:val.client")
endfunction

function! s:suite.get_script_host_client_info() abort
  let client_info = s:client_chans[1]

  call s:expect(sort(keys(client_info))).to_equal(
        \ ["attributes", "methods", "name", "type", "version"])

  call s:expect(client_info.attributes).to_be_dict()
  call s:expect(client_info.methods).to_equal({"specs": {"nargs": 1}, "poll": {}})
  call s:expect(client_info.name).to_equal("ruby-script-host")
  call s:expect(client_info.type).to_equal("host")

  call s:expect(client_info.version.major).to_be_number()
  call s:expect(client_info.version.minor).to_be_number()
  call s:expect(client_info.version.patch).to_be_number()
endfunction

function! s:suite.get_rplugin_client_info() abort
  let client_info = s:client_chans[0]

  call s:expect(sort(keys(client_info))).to_equal(
        \ ["attributes", "methods", "name", "type", "version"])

  call s:expect(client_info.attributes).to_be_dict()
  call s:expect(client_info.methods).to_equal({"specs": {"nargs": 1}, "poll": {}})
  call s:expect(client_info.name).to_equal("ruby-rplugin-host")
  call s:expect(client_info.type).to_equal("host")

  call s:expect(client_info.version.major).to_be_number()
  call s:expect(client_info.version.minor).to_be_number()
  call s:expect(client_info.version.patch).to_be_number()
endfunction
