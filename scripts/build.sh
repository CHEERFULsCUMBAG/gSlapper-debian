#!/usr/bin/env bash
set -euo pipefail

VERSION="$1"
ROOT="$(pwd)"
WORKDIR="$ROOT/build"
LAST_BUILT_FILE="$ROOT/.last-built-version"

LAST_BUILT="none"
if [[ -f "$LAST_BUILT_FILE" ]]; then
  LAST_BUILT="$(cat "$LAST_BUILT_FILE")"
fi

if [[ "$VERSION" == "$LAST_BUILT" ]]; then
  echo "Upstream version $VERSION already built — exiting"
  exit 0
fi

echo "==> Building gSlapper $VERSION"

rm -rf "$WORKDIR"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

echo "==> Cloning gSlapper"
git clone --branch "v$VERSION" --depth 1 \
  https://github.com/Nomadcxx/gSlapper.git gslapper

cd gslapper

echo "==> Creating orig tarball"
cd ..
tar --exclude-vcs -cJf "gslapper_${VERSION}.orig.tar.xz" gslapper
cd gslapper

echo "==> Injecting debian/"
cp -r "$ROOT/debian" .

DATE="$(date -R)"
sed \
  -e "s/@VERSION@/${VERSION}/" \
  -e "s/@DATE@/${DATE}/" \
  debian/changelog.in > debian/changelog
rm debian/changelog.in

echo "==> Building Debian packages"
dpkg-buildpackage -us -uc

echo "==> Build outputs (in $WORKDIR):"
ls -lh "$WORKDIR" || true
ls -lh "$WORKDIR"/*.deb "$WORKDIR"/*.changes "$WORKDIR"/*.buildinfo 2>/dev/null || true

echo "$VERSION" > "$LAST_BUILT_FILE"
