#!/bin/env sh

set -eu

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
. "$script_dir/../lib.sh"

URL='https://slack.com/release-notes/linux'
html="$(curl -fsSL -H "User-Agent: Mozilla/5.0" "$URL")"

title="$(printf '%s' "$html" \
  | awk 'BEGIN{RS="</div>"; IGNORECASE=1} /class="legal-content release-note"/{print; exit}' \
  | awk 'BEGIN{RS="</article>"; IGNORECASE=1} /<article/{print; exit}' \
  | sed -n 's/.*<h2[^>]*>\(.*\)<\/h2>.*/\1/p' \
  | sed 's/<[^>]*>//g' \
  | head -n 1)"

version="$(printf '%s\n' "$title" | sed -E 's/^[[:space:]]*Slack[[:space:]]+//')"

pkgname=$(get_pkgname_from_file "$script_dir/PKGBUILD")
pkgver=$(get_pkgver_from_file "$script_dir/PKGBUILD")
print_update_if_available "$pkgname" "$pkgver" "$version"

exit 0