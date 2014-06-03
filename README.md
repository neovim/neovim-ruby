# Neovim Ruby

Ruby bindings for [Neovim](https://github.com/neovim/neovim).

*Warning*: This project is currently incomplete and unstable. It likely doesn't support any platform besides OS X.

## Installation

Add this line to your application's Gemfile:

    gem "neovim"

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install neovim

## Usage

First, make sure you have [installed the latest version of Neovim](https://github.com/neovim/neovim/wiki/Installing). Start it up with

```sh
NEOVIM_LISTEN_ADDRESS=/tmp/neovim.sock nvim
```

Then in your Ruby file, require `neovim` and instantiate a `Client` to manipulate your Neovim instance:

```ruby
require "neovim"

client = Neovim::Client.new("/tmp/neovim.sock")

# Execute an ex command
client.command('echo "hello"')

# Set a global variable
var = client.variable("var1")
var.value = 12

# Manipulate buffers
buff = client.current_buffer
buff.lines = ["first line", "second line"]
buff.lines[0] # => "first line"
```

See source files and tests for more functionality. New features are being added frequently.

## Running tests

Many of the tests require an active instance of Neovim to run against. Boot one up with `rake neovim:start`. In a separate terminal, you should now be able to run the tests with `rake`.

## Contributing

1. Fork it (http://github.com/alexgenco/neovim-ruby/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
