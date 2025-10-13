#!/bin/env sh

set -eu

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
. "$script_dir/lib.sh"

# Scan all immediate subdirectories with PKGBUILD
for d in "$script_dir"/*/; do
  [ -d "$d" ] || continue
  d_noslash="${d%/}"
  [ -f "$d_noslash/PKGBUILD" ] || continue
  [ -f "$d_noslash/outdated.sh" ] || continue
  (cd "$d_noslash" && ./outdated.sh)
done

exit 0