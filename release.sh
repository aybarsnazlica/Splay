#!/bin/bash
set -euo pipefail

git-cliff --unreleased --bump --prepend CHANGELOG.md

VERSION=$(git-cliff --bumped-version)
VERSION="${VERSION##v}"       # Strip all leading "v"
VERSION="${VERSION##v}"       # In case there's "vv"

git commit -m "feat: bump project version to $VERSION"

git add CHANGELOG.md
git commit -m "docs: update changelog for $VERSION"

git tag -a "v$VERSION" -m "Release v$VERSION"

git push && git push --tags
