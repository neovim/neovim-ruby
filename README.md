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
  # Define a command called "SetLine" which sets the current line to the sum of
  # two values. This command is executed asynchronously, so the return value is
  # ignored.
  plug.command(:SetLine, :nargs => 1) do |nvim, str|
    nvim.current.line = str
  end

  # Define a function called "Sum" which sets the current line. This function
  # is executed synchronously, so the result of the block will be returned to
  # nvim.
  plug.command(:Sum, :nargs => 2, :sync => true) do |nvim, x, y|
    x + y
  end

  # Define an autocmd for the BufEnter event on Ruby files.
  plug.autocmd(:BufEnter, :pattern => "*.rb") do |nvim|
    nvim.command("echom 'Ruby file, eh?'")
  end
end
```

After a call to `:UpdateRemotePlugins`, these plugins will be auto-loaded from the `$VIMRUNTIME/rplugin/ruby` directory.

## Contributing

1. Fork it (http://github.com/alexgenco/neovim-ruby/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
