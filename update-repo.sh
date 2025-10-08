#!/bin/env sh

set -eu

# This script is intended to be run from the repo directory that contains
# the repository database file: myrepo.db.tar.zst
# For each specified subfolder (located under the current repo directory), it
# will copy built packages (*.pkg.tar.zst) into the repo directory and add them
# to the repo database. If no folders are specified, it scans all immediate
# subfolders containing a PKGBUILD.

repo_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
repo_subdir="$repo_dir/repo"
repo_db="$repo_subdir/myrepo.db.tar.zst"

mkdir -p "$repo_subdir"
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
  printf '%s\n' "[copy] -> $repo_subdir"
  # shellcheck disable=SC2086
  cp -f $pkg_list "$repo_subdir/"

  # Build list of copied package paths in repo dir
  copied_list=""
  for pkg in $pkg_list; do
    base=$(basename "$pkg")
    copied_list="$copied_list $repo_subdir/$base"
  done

  printf '%s\n' "[repo-add] myrepo.db.tar.zst <- $(printf '%s' "$copied_list" | sed 's/^ //')"
  # shellcheck disable=SC2086
  repo-add -nRp "$repo_db" $copied_list
}

# If specific folders are provided, use only those (relative to repo_dir unless absolute)
if [ "$#" -gt 0 ]; then
  status=0
  for arg in "$@"; do
    case "$arg" in
      /*) target="$arg" ;;
      *) target="$repo_dir/$arg" ;;
    esac
    add_from_folder "$target" || status=$?
  done
  exit "$status"
fi

# No args: process all immediate subfolders (under repo_dir) that contain a PKGBUILD
status=0
found=0
for d in "$repo_dir"/*/; do
  [ -d "$d" ] || continue
  d_noslash="${d%/}"
  if [ -f "$d_noslash/PKGBUILD" ]; then
    found=1
    add_from_folder "$d_noslash" || status=$?
  fi
done

if [ "$found" -eq 0 ]; then
  printf '%s\n' "No subdirectories with PKGBUILD found under: $repo_dir" >&2
fi

exit "$status"


