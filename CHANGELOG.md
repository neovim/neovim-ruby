# 0.9.1

- Fix bug where `Buffer#[]` with `0` returned the last line of the buffer
  (https://github.com/neovim/neovim-ruby/issues/97)

# 0.9.0

- Add RPC support for `:rubyeval`.
- Add `Neovim::Session#next`.
- Rename `Neovim::Session::Exited` -> `Neovim::Session::Disconnected`.

# 0.8.1

- Set client info on host and client startup
- Add `Client#channel_id`

# 0.8.0

- Allow `Buffer#append` to take a string with newlines
- Use non-strict line indexing in `:rubydo` to prevent line deletions from
  throwing exceptions
- Performance optimizations:
  - Cache RPC method lookups and store them in a set
  - Only flush writes before reading in the event loop
  - Delete request handlers after invoking them
  - Refresh provider globals in a single RPC request

# 0.7.1

- Fix `uninitialized constant Neovim::RubyProvider::StringIO`
- Various backwards-compatible style changes to satisfy Rubocop rules

# 0.7.0

- Drop support for Ruby < 2.2.0, update syntax accordingly
- Use msgpack gem for all reading/writing
- Make provider std stream capturing more robust
- Lazily instantiate Host client on 'poll' request
- Fix windows by setting all IOs to binmode
- Refactor/simplify session and event loop logic

# 0.6.2

- Put IOs into binary mode (fixes windows bugs)
- Various build fixes for appveyor
- Update generated docs to v0.2.2

# 0.6.1

- Add `multi_json` dependency to fix load error in certain envs

# 0.6.0

- Refactor: consolidate "run" logic into EventLoop class to simplify middleware
  layers
- Add JSON structured logging
- Regenerated docs for nvim 0.2.1

# 0.5.1

- Convert vader.vim from submodule to subtree so it is included in gem
  installations

# 0.5.0

- Breaking API changes:
  - Update generated methods to map to `nvim_` RPC functions, rather than the
    deprecated `vim_` ones
  - Remove `Current#range` API, simplifying `LineRange` interface
- Regenerate docs to reflect nvim 0.2.0
- Fix support for `:bang` and `:register` plugin DSL options

# 0.4.0

- Add `Neovim.executable` for accessing `nvim` info
- Fix bug where `$curwin` and `$curbuf` got out of sync after `Vim.command`
  invocations
- Use vader.vim for running vimscript acceptance tests

# 0.3.3

- Hotfix older nvim clients' inability to hook into DirChanged

# 0.3.2

- Fix directory tracking in Ruby provider

# 0.3.1

- Remove window caching to fix incompatibilities with command-t
- Add `Vim` module alias
- Fix `Window.count` and `Window.[]` to work with tabpages
- Fix `EventLoop.child` bug with repeated arguments
- Fix `Window#cursor=` incompatibilities
- Make `Neovim.attach_child` have default argv of `["nvim"]`

# 0.3.0

- Mark `Plugin::DSL#rpc` private
- Rename Session constants:
  - `Neovim::EventLoop` -> `Neovim::Session::EventLoop`
  - `Neovim::MsgpackStream` -> `Neovim::Session::Serializer`
  - `Neovim::AsyncSession` -> `Neovim::Session::RPC`
  - `Neovim::API` -> `Neovim::Session::API`
  - `Neovim::Request` -> `Neovim::Session::Request`
  - `Neovim::Notification` -> `Neovim::Session::Notification`

# 0.2.5

- Optimize remote function lookup
- Fix bug where $curbuf and $curwin weren't persisting instance state between
  requests

# 0.2.4

- Maintain cursor position on Buffer#append for compatibility with vim
- Fix excessive fetching of API metadata

# 0.2.3

- Detach child processes in `Neovim::EventLoop.child`
- Improve performance/compatibility of `Buffer#append`
- Various improvements around `Host` loading

# 0.2.2

- Make `VIM` constant a module instead of a class
- Make `Client#set_option` accept a single string argument

# 0.2.1

- Fix race condition in Fiber handling
- General improvements to ruby\_provider.rb

# 0.2.0

- Backwards incompatible, but we're pre-1.0.0 so going with minor bump instead
- Make vim ruby functions 1-indexed
- Add Client#evaluate and Client#message
- Make ruby functions affect global scope
- Add VIM::{Buffer,Window}.{count,index}
- Add minor debug logging to Session and AsyncSession
- Remove race condition in Session fiber handling

# 0.1.0

- Add --version, -V to neovim-ruby-host executable
- Update object interfaces to be compatible with Vim :ruby API
- `NVIM_RUBY_LOG_LEVEL` now takes strings, e.g. `DEBUG`
- Add `rpc` plugin DSL method for exposing top-level functions
- Add `ruby_provider.rb` for Vim :ruby API compatibility
- Remove Cursor class
- Remove vendored `neovim`

# 0.0.6

- Update Session with improved Fiber coordination
- Documentation
- Rename APIInfo -> API
- Rename Object -> RemoteObject

# 0.0.5

- Various fixes for Ruby remote plugins
- Move Current#range and #range= methods to Buffer
- Add better logging

# 0.0.4

- Add support for loading Ruby remote plugins from nvim
- Add Current#range to return a LineRange enumerable object
- Support sending large messages
- Remove unnecessary #stop methods
- Add setup callback support to event loop

# 0.0.3

- Add Buffer#lines enumerable interface
- Add Window#cursor interface
- Fix race condition when loading plugins from host

# 0.0.2

- Add Neovim.plugin DSL for defining plugins
- Add neovim-ruby-host executable for spawning plugins
