#!/bin/sh

set -euo pipefail

: ${TRAVIS:?} ${BUILD:?}

NVIM_EXECUTABLE="${NVIM_EXECUTABLE:-"$PWD/_bin/nvim"}"

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

mkdir -p "$(dirname "$NVIM_EXECUTABLE")"

wget "https://github.com/neovim/neovim/releases/$URL_PART/nvim.appimage" \
  -O "$NVIM_EXECUTABLE"

chmod u+x "$NVIM_EXECUTABLE"

"$NVIM_EXECUTABLE" --version
