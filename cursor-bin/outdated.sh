#!/bin/env sh

set -eu

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
. "$script_dir/../lib.sh"

get_cursor_full_version() {
  local url fname
  url=$(curl -fsSL -H "User-Agent: Mozilla/5.0" https://cursor.com/download \
    | grep -oE "https://api2\.cursor\.sh/updates/download/golden/linux-x64-deb/cursor/[0-9]+\.[0-9]+" | head -n1) || return 1
  
  fname=$(curl -fsSLI -H "User-Agent: Mozilla/5.0" -L -o /dev/null -w '%{url_effective}\n' "$url") || return 2

  echo "$fname" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+'
}

pkgname=$(get_pkgname_from_file "$script_dir/PKGBUILD")
pkgver=$(get_pkgver_from_file "$script_dir/PKGBUILD")
latest_ver=$(get_cursor_full_version)
print_update_if_available "$pkgname" "$pkgver" "$latest_ver"

exit 0