#!/usr/bin/env bash
set -euo pipefail

UPSTREAM_REPO="https://github.com/Nomadcxx/gSlapper.git"

latest_tag="$(
  git ls-remote --tags --refs "$UPSTREAM_REPO" \
  | awk '{print $2}' \
  | sed 's|refs/tags/||' \
  | sort -V \
  | tail -n1
)"

# strip leading v if present
latest_version="${latest_tag#v}"

echo "$latest_version"
