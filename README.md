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

The interface of the client is generated at runtime from the `vim_get_api_info` RPC call. For now, you can refer to the Node client's auto-generated [API description](https://github.com/neovim/node-client/blob/master/index.d.ts). Note that methods will be in `snake_case` rather than `camelCase`.

You can also define plugins that nvim can spawn and communicate with via its MessagePack RPC API. Here's an example plugin definition:

```ruby
#!/usr/bin/env ruby

require "neovim"

plugin = Neovim.plugin do |plug|
  plug.on_request do |request, nvim|
    # nvim has sent a request to the process and is waiting on a response.
    # The `respond` method will send a response back.
    request.respond("OK")
  end

  plug.on_notification do |notification, nvim|
    # nvim has sent a notification to the process and will not wait for a response.
    nvim.current.line = "Received notification #{notification.method_name} with arguments #{notification.arguments}"
  end
end

plugin.run
```

To run this script from nvim:

```vim
" Start the plugin process to get a channel ID
let g:channel = rpcstart("/path/to/script")

" Send a request and get a response
let g:response = rpcrequest(g:channel, "my_request", "arg1", "arg2)

" Send a notification
call rpcnotify(g:channel, "my_notification", "arg1", "arg2")
```

## Contributing

1. Fork it (http://github.com/alexgenco/neovim-ruby/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
