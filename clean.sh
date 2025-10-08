#!/bin/env sh

# Remove all files and directories inside package subfolders except the PKGBUILD.
# - With args: clean only the given subfolders (skips repo/)
# - Without args: clean all immediate subfolders that contain a PKGBUILD (skips repo/)

set -eu

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
repo_subdir="$script_dir/repo"

clean_one() {
  dir="$1"
  if [ "$dir" = "$repo_subdir" ] || [ "$(basename "$dir")" = "repo" ]; then
    printf '%s\n' "[skip] Skipping repo directory: $dir" >&2
    return 0
  fi
  if [ ! -d "$dir" ]; then
    printf '%s\n' "[skip] Not a directory: $dir" >&2
    return 0
  fi
  if [ ! -f "$dir/PKGBUILD" ]; then
    printf '%s\n' "[skip] No PKGBUILD in: $dir" >&2
    return 0
  fi
  printf '%s\n' "[clean] $dir -> removing everything except PKGBUILD"
  find "$dir" -mindepth 1 -maxdepth 1 ! -name 'PKGBUILD' -exec rm -rf {} +
}

# If arguments are provided, clean only those directories
if [ "$#" -gt 0 ]; then
  status=0
  for arg in "$@"; do
    case "$arg" in
      /*) target="$arg" ;;
      *) target="$script_dir/$arg" ;;
    esac
    clean_one "$target" || status=$?
  done
  exit "$status"
fi

# No arguments: clean all subdirectories that contain a PKGBUILD
status=0
found=0
for d in "$script_dir"/*/; do
  [ -d "$d" ] || continue
  d_noslash="${d%/}"
  [ "$d_noslash" = "$repo_subdir" ] && continue
  if [ -f "$d_noslash/PKGBUILD" ]; then
    found=1
    clean_one "$d_noslash" || status=$?
  fi
done

if [ "$found" -eq 0 ]; then
  printf '%s\n' "No subdirectories with PKGBUILD found under: $script_dir" >&2
fi

exit "$status"


