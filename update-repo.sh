#!/bin/env sh

set -eu

# This script requires a repo directory as the first argument.
# It will copy built packages (*.pkg.tar.zst) from specified subfolders into the repo directory
# and add them to the repo database. If no folders are specified, it scans all immediate
# subfolders containing a PKGBUILD.

if [ "$#" -lt 1 ]; then
  printf '%s\n' "Usage: $0 <repo_dir> [package_dir1] [package_dir2] ..." >&2
  printf '%s\n' "  repo_dir: directory containing the repository database" >&2
  printf '%s\n' "  package_dir: optional package directories to process" >&2
  exit 1
fi

repo_dir="$1"
shift

if [ ! -d "$repo_dir" ]; then
  printf '%s\n' "Error: repo directory does not exist: $repo_dir" >&2
  exit 1
fi

repo_db="$repo_dir/myrepo.db.tar.zst"

if [ ! -f "$repo_db" ]; then
  printf '%s\n' "[warn] Repo database not found, will be created: $repo_db"
fi

add_from_folder() {
  folder_path="$1"
  if [ ! -d "$folder_path" ]; then
    printf '%s\n' "[skip] Not a directory: $folder_path" >&2
    return 0
  fi
  # Collect package files
  # Use find to avoid unexpanded globs when no matches
  pkg_list=$(find "$folder_path" -maxdepth 1 -type f -name '*.pkg.tar.zst' | sort)
  if [ -z "$pkg_list" ]; then
    printf '%s\n' "[skip] No packages found in: $folder_path" >&2
    return 0
  fi
  # Copy packages into repo dir first
  printf '%s\n' "[copy] -> $repo_dir"
  # shellcheck disable=SC2086
  cp -f $pkg_list "$repo_dir/"

  # Build list of copied package paths in repo dir
  copied_list=""
  for pkg in $pkg_list; do
    base=$(basename "$pkg")
    copied_list="$copied_list $repo_dir/$base"
  done

  printf '%s\n' "[repo-add] myrepo.db.tar.zst <- $(printf '%s' "$copied_list" | sed 's/^ //')"
  # shellcheck disable=SC2086
  repo-add -nRp "$repo_db" $copied_list
}

# If specific folders are provided, use only those (relative to current dir unless absolute)
if [ "$#" -gt 0 ]; then
  status=0
  for arg in "$@"; do
    case "$arg" in
      /*) target="$arg" ;;
      *) target="$(pwd)/$arg" ;;
    esac
    add_from_folder "$target" || status=$?
  done
  exit "$status"
fi

# No args: process all immediate subfolders (under current dir) that contain a PKGBUILD
status=0
found=0
for d in ./*/; do
  [ -d "$d" ] || continue
  d_noslash="${d%/}"
  if [ -f "$d_noslash/PKGBUILD" ]; then
    found=1
    add_from_folder "$d_noslash" || status=$?
  fi
done

if [ "$found" -eq 0 ]; then
  printf '%s\n' "No subdirectories with PKGBUILD found under: $(pwd)" >&2
fi

exit "$status"


