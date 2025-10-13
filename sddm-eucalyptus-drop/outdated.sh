#!/bin/env sh

set -eu

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
. "$script_dir/../lib.sh"

check_gitlab_latest_release "$script_dir/PKGBUILD" "Matt.Jolly" "sddm-eucalyptus-drop"

exit 0