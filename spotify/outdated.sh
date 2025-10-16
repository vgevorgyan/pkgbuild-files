#!/bin/env sh

set -eu

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
. "$script_dir/../lib.sh"

URL="https://repository.spotify.com/pool/non-free/s/spotify-client/"

latest_version=$(
  curl -fsSL "$URL" |
    grep -oE 'spotify-client_[^"]+_amd64\.deb' |
    sed -E 's/^spotify-client_([^_]+)\..+_amd64\.deb/\1/' |
    sort -V |
    tail -n1
)

pkgname=$(get_pkgname_from_file "$script_dir/PKGBUILD")
pkgver=$(get_pkgver_from_file "$script_dir/PKGBUILD")
print_update_if_available "$pkgname" "$pkgver" "$latest_version"

exit 0

