# Neovim Ruby

[![Travis](https://travis-ci.org/alexgenco/neovim-ruby.svg?branch=master)](https://travis-ci.org/alexgenco/neovim-ruby)
[![Coverage Status](https://coveralls.io/repos/alexgenco/neovim-ruby/badge.png)](https://coveralls.io/r/alexgenco/neovim-ruby)

Ruby bindings for [Neovim](https://github.com/neovim/neovim).

*Warning*: This project is currently incomplete and unstable.

## Installation

Add this line to your application's Gemfile:

    source 'https://rubygems.org'
    gem 'neovim', git: 'https://github.com/alexgenco/neovim-ruby/'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install neovim

*Warning*: This project is not in rubygems repository yet.

## Usage

You can control a running `nvim` process by connecting to `$NVIM_LISTEN_ADDRESS`. Start it up like this:

```shell
$ NVIM_LISTEN_ADDRESS=/tmp/nvim.sock nvim
```

In Ruby, create an `IO` object connected to that socket and pass it to a `Neovim::Client`:

```shell
$ bundle exec irb
irb(main):001:0> require 'socket'
irb(main):002:0> require 'neovim'
irb(main):003:0> socket = UNIXSocket.new(ENV["NVIM_LISTEN_ADDRESS"])
irb(main):004:0> client = Neovim::Client.new(socket)
```

```ruby
require 'socket'
require 'neovim'
socket = UNIXSocket.new(ENV["NVIM_LISTEN_ADDRESS"])
client = Neovim::Client.new(socket)
```

Start in [client.rb](lib/neovim/client.rb) to see what client functions are currently supported.

## Contributing

1. Fork it (http://github.com/alexgenco/neovim-ruby/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
