#!/bin/env sh

set -eu

# Shared library for PKGBUILD tooling

# Get pkgname from a PKGBUILD file path
get_pkgname_from_file() {
  pkgb_file="$1"
  [ -f "$pkgb_file" ] || { printf '%s\n' ""; return 1; }
  awk '
    BEGIN { name="" }
    /^pkgname=/ {
      line=$0
      sub(/^pkgname=/, "", line)
      gsub(/^[ \t]*/, "", line)
      gsub(/["\047]/, "", line)
      if (line ~ /^\(/) {
        sub(/^\(/, "", line)
        sub(/\).*/, "", line)
        n=split(line, arr, /[ \t]+/)
        if (n>0) { print arr[1]; exit }
      } else {
        print line; exit
      }
    }
  ' "$pkgb_file"
}

# Get pkgver from a PKGBUILD file path
get_pkgver_from_file() {
  pkgb_file="$1"
  [ -f "$pkgb_file" ] || { printf '%s\n' ""; return 1; }
  awk '
    /^pkgver=/ {
      line=$0
      sub(/^pkgver=/, "", line)
      gsub(/^[ \t]*/, "", line)
      gsub(/["\047]/, "", line)
      print line; exit
    }
  ' "$pkgb_file"
}

# Fetch the latest release version from GitHub
get_github_latest_release() {
  owner="$1"
  repo="$2"
  json=$(curl -fsSL "https://api.github.com/repos/$owner/$repo/releases/latest" 2>/dev/null || true)
  if command -v jq >/dev/null 2>&1; then
    latest_ver=$(printf '%s' "$json" | jq -r '.tag_name // empty')
  else
    latest_ver=$(printf '%s' "$json" | grep -m1 -o '"tag_name"[^"]*"[^"]*"' | sed -E 's/.*"tag_name"[^"]*"([^"]*)"/\1/')
  fi
  case "$latest_ver" in v*|V*) latest_ver="${latest_ver#v}"; latest_ver="${latest_ver#V}" ;; esac
  printf '%s\n' "$latest_ver"
}

# Fetch the latest release version from GitLab
get_gitlab_latest_release() {
  owner="$1"
  repo="$2"
  json=$(curl -fsSL "https://gitlab.com/api/v4/projects/$owner%2F$repo/releases/permalink/latest" 2>/dev/null || true)
  if command -v jq >/dev/null 2>&1; then
    latest_ver=$(printf '%s' "$json" | jq -r '.tag_name // empty')
  else
    latest_ver=$(printf '%s' "$json" | grep -m1 -o '"tag_name"[^"]*"[^"]*"' | sed -E 's/.*"tag_name"[^"]*"([^"]*)"/\1/')
  fi
  case "$latest_ver" in v*|V*) latest_ver="${latest_ver#v}"; latest_ver="${latest_ver#V}" ;; esac
  printf '%s\n' "$latest_ver"
}

# Print a one-line update message if latest version differs from pkgver
print_update_if_available() {
  pkgname="$1"
  pkgver="$2"
  latest_ver="$3"
  if [ -n "$latest_ver" ] && [ "$latest_ver" != "$pkgver" ]; then
    printf '%s: \t%s -> %s\n' "$pkgname" "$pkgver" "$latest_ver"
  fi
}

# Convenience wrapper: read pkgname/pkgver from PKGBUILD and compare to GitHub latest
check_github_latest_release() {
  pkgb_file="$1"
  owner="$2"
  repo="$3"
  pkgname=$(get_pkgname_from_file "$pkgb_file")
  pkgver=$(get_pkgver_from_file "$pkgb_file")
  latest_ver=$(get_github_latest_release "$owner" "$repo")
  print_update_if_available "$pkgname" "$pkgver" "$latest_ver"
}

# Convenience wrapper: read pkgname/pkgver from PKGBUILD and compare to GitLab latest
check_gitlab_latest_release() {
  pkgb_file="$1"
  owner="$2"
  repo="$3"
  pkgname=$(get_pkgname_from_file "$pkgb_file")
  pkgver=$(get_pkgver_from_file "$pkgb_file")
  latest_ver=$(get_gitlab_latest_release "$owner" "$repo")
  print_update_if_available "$pkgname" "$pkgver" "$latest_ver"
}