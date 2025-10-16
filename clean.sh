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

  # Check if .gitignore exists in this directory
  if [ -f "$dir/.gitignore" ]; then
    printf '%s\n' "[clean] $dir -> removing files not marked with ! in .gitignore (preserving PKGBUILD)"
    # First, collect all files to keep (those marked with !)
    keep_files=""
    while IFS= read -r pattern; do
      # Skip empty lines and comments
      [ -z "$pattern" ] && continue
      case "$pattern" in
      \#*) continue ;;                    # Skip comments
      !*)                                 # Files to keep (marked with !)
        keep_pattern="${pattern#!}"       # Remove the ! prefix
        keep_pattern="${keep_pattern#./}" # Remove leading ./ if present
        case "$keep_pattern" in
        /*) # Absolute path from directory root
          keep_files="$keep_files $dir$keep_pattern"
          ;;
        *) # Relative path
          keep_files="$keep_files $dir/$keep_pattern"
          ;;
        esac
        ;;
      esac
    done <"$dir/.gitignore"

    # Always keep PKGBUILD and .gitignore
    keep_files="$keep_files $dir/PKGBUILD $dir/.gitignore"

    # Now delete everything except the files we want to keep
    find "$dir" -mindepth 1 -maxdepth 1 -type f | while read -r file; do
      should_keep=false
      for keep_file in $keep_files; do
        if [ "$file" = "$keep_file" ]; then
          should_keep=true
          break
        fi
      done
      if [ "$should_keep" = false ]; then
        printf '%s\n' "  [rm] $(basename "$file")"
        rm -f "$file"
      fi
    done

    # Handle directories
    find "$dir" -mindepth 1 -maxdepth 1 -type d | while read -r dir_file; do
      should_keep=false
      for keep_file in $keep_files; do
        if [ "$dir_file" = "$keep_file" ]; then
          should_keep=true
          break
        fi
      done
      if [ "$should_keep" = false ]; then
        printf '%s\n' "  [rm] $(basename "$dir_file")"
        sudo rm -rf "$dir_file"
      fi
    done
  else
    printf '%s\n' "[clean] $dir -> removing everything except PKGBUILD"
    find "$dir" -mindepth 1 -maxdepth 1 ! -name 'PKGBUILD' -exec rm -rf {} +
  fi
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
