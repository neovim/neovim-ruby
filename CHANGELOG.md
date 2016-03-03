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
