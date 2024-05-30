local chan

local function ensure_job()
  if chan then
    return chan
  end

  chan = vim.fn.jobstart({
    'ruby',
    '-I', 'lib',
    'spec/acceptance/runtime/example_remote_module.rb',
  }, { rpc = true })

  return chan
end

vim.api.nvim_create_user_command('RbSetVar', function(args)
  vim.fn.rpcrequest(ensure_job(), 'rb_set_var', args.fargs)
end, { nargs = '*' })

vim.api.nvim_create_user_command('RbWillRaise', function(args)
  vim.fn.rpcrequest(ensure_job(), 'rb_will_raise', args.fargs)
end, { nargs = 0 })
