# Neovim Ruby

[![Gem Version](https://badge.fury.io/rb/neovim.svg)](https://badge.fury.io/rb/neovim)
[![Travis](https://travis-ci.org/alexgenco/neovim-ruby.svg?branch=master)](https://travis-ci.org/alexgenco/neovim-ruby)
[![Coverage Status](https://coveralls.io/repos/alexgenco/neovim-ruby/badge.png)](https://coveralls.io/r/alexgenco/neovim-ruby)
[![Code Climate](https://codeclimate.com/github/alexgenco/neovim-ruby/badges/gpa.svg)](https://codeclimate.com/github/alexgenco/neovim-ruby)

Ruby bindings for [Neovim](https://github.com/neovim/neovim).

*Warning*: This project follows [Semantic Versioning](http://semver.org/), thus its API should be considered unstable until it reaches v1.0.0 ([spec](http://semver.org/#spec-item-4)).

## Installation

Add this line to your application's Gemfile:

    gem "neovim"

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install neovim

## Usage

You can control a running `nvim` process by connecting to `$NVIM_LISTEN_ADDRESS`. For example, to connect to `nvim` over a UNIX domain socket, start it up like this:

```shell
$ NVIM_LISTEN_ADDRESS=/tmp/nvim.sock nvim
```

You can then connect to that socket path to get a `Neovim::Client`:

```ruby
require "neovim"
client = Neovim.attach_unix("/tmp/nvim.sock")
```

Refer to the [`Neovim` docs](http://www.rubydoc.info/github/alexgenco/neovim-ruby/master/Neovim) for other ways to connect to `nvim`, and the [`Neovim::Client` docs](http://www.rubydoc.info/github/alexgenco/neovim-ruby/master/Neovim/Client) for a summary of the client interface.

### Plugins

The `neovim-ruby-host` executable can be used to spawn Ruby plugins via the `rpcstart` command. A plugin can be defined like this:

```ruby
# $VIMRUNTIME/rplugin/ruby/my_plugin.rb

Neovim.plugin do |plug|
  # Define a command called "SetLine" which sets the contents of the current
  # line. This command is executed asynchronously, so the return value is
  # ignored.
  plug.command(:SetLine, :nargs => 1) do |nvim, str|
    nvim.current.line = str
  end

  # Define a function called "Sum" which adds two numbers. This function is
  # executed synchronously, so the result of the block will be returned to nvim.
  plug.function(:Sum, :nargs => 2, :sync => true) do |nvim, x, y|
    x + y
  end

  # Define an autocmd for the BufEnter event on Ruby files.
  plug.autocmd(:BufEnter, :pattern => "*.rb") do |nvim|
    nvim.command("echom 'Ruby file, eh?'")
  end
end
```

Ruby plugins go in the `$VIMRUNTIME/rplugin/ruby` directory, and are auto-loaded after calling `:UpdateRemotePlugins`. Refer to the [`Neovim::Plugin::DSL` docs](http://www.rubydoc.info/github/alexgenco/neovim-ruby/master/Neovim/Plugin/DSL) for a more complete overview.

The Neovim gem also acts as a compatibility layer for Ruby plugins written for legacy `vim`. The `:ruby`, `:rubyfile`, and `:rubydo` commands are intended to behave the same as they did in `vim`, and their documentation can be found [here](https://neovim.io/doc/user/if_ruby.html).

## Links

* Source: <http://github.com/alexgenco/neovim-ruby>
* Bugs:   <http://github.com/alexgenco/neovim-ruby/issues>
* CI: <http://travis-ci.org/alexgenco/neovim-ruby>
* Documentation:
    * Latest Gem: <http://rubydoc.info/gems/neovim>
    * Master: <http://rubydoc.info/github/alexgenco/neovim-ruby/master/frames>

## Contributing

1. Fork it (http://github.com/alexgenco/neovim-ruby/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
