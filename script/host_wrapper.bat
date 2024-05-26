#!/usr/bin/env bash

cd "$(dirname "$0")/.."

exec ruby -I ./lib ./exe/neovim-ruby-host "$@"
