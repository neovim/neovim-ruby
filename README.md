# Neovim Ruby

[![Build Status](https://github.com/neovim/neovim-ruby/workflows/Tests/badge.svg)](https://github.com/neovim/neovim-ruby/actions)
[![Gem Version](https://badge.fury.io/rb/neovim.svg)](https://badge.fury.io/rb/neovim)

Ruby support for [Neovim](https://github.com/neovim/neovim).

## Installation

Add this line to your application's Gemfile:

```ruby
gem "neovim"
```

And then execute:

```shell
bundle
```

Or install it yourself as:

```shell
gem install neovim
```

## Usage

Neovim supports the `--listen` option for specifying an address to serve its RPC API. To connect to Neovim over a Unix socket, start it up like this:

```shell
$ nvim --listen /tmp/nvim.sock
```

You can then connect to that socket path to get a `Neovim::Client`:

```ruby
require "neovim"
client = Neovim.attach_unix("/tmp/nvim.sock")
```

Refer to the [`Neovim` docs](https://www.rubydoc.info/github/neovim/neovim-ruby/main/Neovim) for other ways to connect to `nvim`, and the [`Neovim::Client` docs](https://www.rubydoc.info/github/neovim/neovim-ruby/main/Neovim/Client) for a summary of the client interface.

### Plugins

Plugins are Ruby files loaded from the `$VIMRUNTIME/rplugin/ruby/` directory. Here's an example plugin:

```ruby
# ~/.config/nvim/rplugin/ruby/example_plugin.rb

Neovim.plugin do |plug|
  # Define a command called "SetLine" which sets the contents of the current
  # line. This command is executed asynchronously, so the return value is
  # ignored.
  plug.command(:SetLine, nargs: 1) do |nvim, str|
    nvim.current.line = str
  end

  # Define a function called "Sum" which adds two numbers. This function is
  # executed synchronously, so the result of the block will be returned to nvim.
  plug.function(:Sum, nargs: 2, sync: true) do |nvim, x, y|
    x + y
  end

  # Define an autocmd for the BufEnter event on Ruby files.
  plug.autocmd(:BufEnter, pattern: "*.rb") do |nvim|
    nvim.command("echom 'Ruby file, eh?'")
  end
end
```

When you add or update a plugin, you will need to call `:UpdateRemotePlugins` to update the remote plugin manifest. See `:help remote-plugin-manifest` for more information.

Refer to the [`Neovim::Plugin::DSL` docs](https://www.rubydoc.info/github/neovim/neovim-ruby/main/Neovim/Plugin/DSL) for a more complete overview of the `Neovim.plugin` DSL.

### Vim Plugin Support

The Neovim gem also acts as a compatibility layer for Ruby plugins written for `vim`. The `:ruby`, `:rubyfile`, and `:rubydo` commands are intended to match their original behavior, and their documentation can be found [here](https://neovim.io/doc/user/if_ruby.html).

## Links

* Source: <https://github.com/neovim/neovim-ruby>
* Bugs: <https://github.com/neovim/neovim-ruby/issues>
* CI: <https://github.com/neovim/neovim-ruby/actions>
* Documentation:
  * Latest Gem: <https://rubydoc.info/gems/neovim>
  * Main: <https://rubydoc.info/github/neovim/neovim-ruby/main>

## Contributing

1. Fork it (<https://github.com/neovim/neovim-ruby/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
