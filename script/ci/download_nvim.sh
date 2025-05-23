#!/usr/bin/env bash

set -eu

: ${RUNNER_OS:?}

case "$(echo "$RUNNER_OS" | tr "[:upper:]" "[:lower:]")" in
  macos)
    wget -nv -P /tmp \
      "https://github.com/neovim/neovim/releases/download/stable/nvim-macos-x86_64.tar.gz"
    tar -C /tmp -xzf /tmp/nvim-macos-x86_64.tar.gz
    mv /tmp/nvim-macos-x86_64 ./_nvim
    ;;
  linux)
    mkdir -p _nvim/bin
    wget -nv -O _nvim/bin/nvim \
      "https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.appimage"
    ;;
  *)
    echo "Unrecognized \$RUNNER_OS" >&2
    exit 1
    ;;
esac

chmod u+x _nvim/bin/nvim

_nvim/bin/nvim --version
