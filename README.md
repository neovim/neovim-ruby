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

### Remote Modules

Remote modules allow users to define custom handlers in Ruby. To implement a remote module:

- Define your handlers in a plain Ruby script that imports `neovim`
- Spawn the script from lua using `jobstart`
- Define commands in lua using `nvim_create_user_command` that route to the job's channel ID

For usage examples, see:

- [`example_remote_module.rb`](spec/acceptance/runtime/example_remote_module.rb)
- [`example_remote_module.lua`](spec/acceptance/runtime/plugin/example_remote_module.lua)
- [`remote_module_spec.vim`](spec/acceptance/remote_module_spec.vim)

*Note*: Remote modules are a replacement for the deprecated "remote plugin" architecture. See https://github.com/neovim/neovim/issues/27949 for details.

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
