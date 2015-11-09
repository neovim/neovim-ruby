# Neovim Ruby

[![Gem Version](https://badge.fury.io/rb/neovim.svg)](https://badge.fury.io/rb/neovim)
[![Travis](https://travis-ci.org/alexgenco/neovim-ruby.svg?branch=master)](https://travis-ci.org/alexgenco/neovim-ruby)
[![Coverage Status](https://coveralls.io/repos/alexgenco/neovim-ruby/badge.png)](https://coveralls.io/r/alexgenco/neovim-ruby)

Ruby bindings for [Neovim](https://github.com/neovim/neovim).

*Warning*: This project is currently incomplete and unstable.

## Installation

Add this line to your application's Gemfile:

    gem "neovim"

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install neovim

## Usage

You can control a running `nvim` process by connecting to `$NVIM_LISTEN_ADDRESS`. Start it up like this:

```shell
$ NVIM_LISTEN_ADDRESS=/tmp/nvim.sock nvim
```

You can then connect to that socket to get a `Neovim::Client`:

```ruby
require "neovim"
client = Neovim.attach_unix("/tmp/nvim.sock")
```

The client's interface is generated at runtime from the `vim_get_api_info` RPC call. For now, you can refer to the Node client's auto-generated [API description](https://github.com/neovim/node-client/blob/master/index.d.ts). Note that methods will be in `snake_case` rather than `camelCase`.

The `neovim-ruby-host` executable can be used to spawn Ruby plugins via the `rpcstart` command. A plugin can be defined like this:

```ruby
# my_plugin.rb

Neovim.plugin do |plug|
  # Define a command called "Add" which returns the sum of two numbers
  # The `:sync => true` option tells nvim to wait for a response.
  # The result of the block will be returned to nvim.
  plug.command(:Add, :nargs => 2, :sync => true) do |nvim, x, y|
    x + y
  end
  
  # Define a command called "SetLine" which sets the current line
  # This command is asynchronous, so nvim won't wait for a response.
  plug.command(:SetLine, :nargs => 1) do |nvim, str|
    nvim.current.line = str
  end
end
```

You can start this plugin via the `rpcstart` nvim function. The resulting channel ID can be used to send requests and notifications to the plugin.

```viml
let host = rpcstart("neovim-ruby-host", ["./my_plugin.rb"])

let result = rpcrequest(host, "Add", 1, 2) " result is set to 3
call rpcnotify(host, "SetLine", "Foo")     " current line is set to 'Foo'
```

Plugin functionality is very limited right now. Besides `command`, the plugin DSL exposes the `function` and `autocmd` directives, however they are functionally almost identical to `command`. Their purpose is to define a manifest that nvim can load via the `UpdateRemotePlugins` command, which will generate the actual `command`, `function`, and `autocmd` definitions. This piece has not yet been implemented.

## Contributing

1. Fork it (http://github.com/alexgenco/neovim-ruby/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
