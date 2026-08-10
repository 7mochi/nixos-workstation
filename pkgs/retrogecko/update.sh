#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
FILE="$ROOT_DIR/default.nix"

new_version="$(curl -fsSL "https://jvyden.xyz/gex/retro/" | grep -oE 'retrogecko-b[0-9]+-linux-x64\.zip' | sort -Vu | tail -1 | sed -E 's/retrogecko-(b[0-9]+)-linux-x64\.zip/\1/')"

new_url="https://jvyden.xyz/gex/retro/retrogecko-${new_version}-linux-x64.zip"
sri_hash="$(nix-prefetch-url --unpack "$new_url" | xargs nix hash convert --hash-algo sha256 --to sri)"

sed -i -e "s|version = \".*\"|version = \"$new_version\"|g" "$FILE"
sed -i -e "s|hash = \".*\"|hash = \"$sri_hash\"|g" "$FILE"
