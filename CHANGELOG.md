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
