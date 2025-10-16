#!/bin/env sh

set -eu

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
. "$script_dir/../lib.sh"

check_github_latest_release "$script_dir/PKGBUILD" "obsidianmd" "obsidian-releases"

exit 0

