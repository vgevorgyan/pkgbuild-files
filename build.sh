#!/bin/env sh

# Build Arch packages in specified subfolders or, if none specified, all subfolders.
# - With args: for each folder containing a PKGBUILD, run: makepkg -sD
# - Without args: prompt for confirmation, then build all PKGBUILD subfolders

set -eu

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"

build_one() {
  dir="$1"
  if [ ! -d "$dir" ]; then
    printf '%s\n' "[skip] Not a directory: $dir" >&2
    return 0
  fi
  if [ ! -f "$dir/PKGBUILD" ]; then
    printf '%s\n' "[skip] No PKGBUILD in: $dir" >&2
    return 0
  fi
  printf '%s\n' "[build] $dir -> makepkg -sD"
  (makepkg -sD $dir)
}

# If arguments are provided, build only those directories
if [ "$#" -gt 0 ]; then
  status=0
  for arg in "$@"; do
    case "$arg" in
      /*) target="$arg" ;;
      *) target="$script_dir/$arg" ;;
    esac
    build_one "$target" || status=$?
  done
  exit "$status"
fi

# No arguments: confirm building all packages
printf '%s' "are you sure that you want to build all packages? [y/N]: "
IFS= read -r answer || answer="n"
case "$answer" in
  y|Y|yes|YES) ;;
  *)
    printf '%s\n' "Aborted."
    exit 1
    ;;
esac

# Build all subdirectories that contain a PKGBUILD
status=0
found=0
for d in "$script_dir"/*/; do
  [ -d "$d" ] || continue
  # remove trailing slash for logging consistency
  d_noslash="${d%/}"
  if [ -f "$d_noslash/PKGBUILD" ]; then
    found=1
    build_one "$d_noslash" || status=$?
  fi
done

if [ "$found" -eq 0 ]; then
  printf '%s\n' "No subdirectories with PKGBUILD found under: $script_dir" >&2
fi

exit "$status"
