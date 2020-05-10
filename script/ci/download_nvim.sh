#!/usr/bin/env bash

set -eu

: ${RUNNER_OS:?} ${BUILD:?}

case "$BUILD" in
  latest)
    URL_PART="latest/download"
    ;;
  nightly)
    URL_PART="download/nightly"
    ;;
  *)
    echo "BUILD must be 'latest' or 'nightly'." >&2
    exit 1
    ;;
esac

case "$(echo "$RUNNER_OS" | tr "[:upper:]" "[:lower:]")" in
  macos)
    wget -nv -P /tmp \
      "https://github.com/neovim/neovim/releases/$URL_PART/nvim-macos.tar.gz"
    tar -C /tmp -xzf /tmp/nvim-macos.tar.gz
    mv /tmp/nvim-osx64 ./_nvim
    ;;
  linux)
    mkdir -p _nvim/bin
    wget -nv -O _nvim/bin/nvim \
      "https://github.com/neovim/neovim/releases/$URL_PART/nvim.appimage"
    ;;
  *)
    echo "Unrecognized \$RUNNER_OS" >&2
    exit 1
    ;;
esac

chmod u+x _nvim/bin/nvim

_nvim/bin/nvim --version
