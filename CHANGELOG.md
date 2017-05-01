# 0.4.0
- Add `Neovim.executable` for accessing `nvim` info
- Fix bug where `$curwin` and `$curbuf` got out of sync after `Vim.command`
  invocations
- Use vader.vim for running vimscript acceptance tests

# 0.3.3
- Hotfix older nvim clients' inability to hook into DirChanged

# 0.3.2
- Fix directory tracking in legacy Ruby provider

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
- Make legacy ruby functions 1-indexed
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
- Remove unecessary #stop methods
- Add setup callback support to event loop

# 0.0.3

- Add Buffer#lines enumerable interface
- Add Window#cursor interface
- Fix race condition when loading plugins from host

# 0.0.2

- Add Neovim.plugin DSL for defining plugins
- Add neovim-ruby-host executable for spawning plugins
