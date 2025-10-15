#!/bin/env sh

set -eu

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
. "$script_dir/../lib.sh"

URL="https://zoom.us/client/latest/zoom_amd64.deb"

ver=$(curl -sI "$URL" | grep -i '^location:' | sed -E 's#.*/prod/([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/.*#\1#')
latest_ver="${ver%.*}"
build="${ver##*.}"

pkgname=$(get_pkgname_from_file "$script_dir/PKGBUILD")
pkgver=$(get_pkgver_from_file "$script_dir/PKGBUILD")
subver=$(get_subver_from_file "$script_dir/PKGBUILD")
print_update_if_available_subver "$pkgname" "$pkgver" "$subver" "$latest_ver" "$build"

exit 0

