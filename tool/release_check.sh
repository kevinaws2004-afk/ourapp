#!/usr/bin/env bash
# Automatic part of docs/RELEASE_CHECKLIST.md: version bumped, analyze,
# tests, release app bundle. Stops at the first failure.
set -euo pipefail
cd "$(dirname "$0")/.."

version=$(grep -E '^version:' pubspec.yaml | awk '{print $2}')
code=${version#*+}
echo "Version $version (version code $code)"
if [[ -f .last_release_code ]]; then
  last=$(cat .last_release_code)
  if (( code <= last )); then
    echo "✗ Version code $code isn't higher than the last release ($last)."
    echo "  Bump the number after + in pubspec.yaml."
    exit 1
  fi
fi

echo "→ flutter analyze"
flutter analyze

echo "→ flutter test"
flutter test

if [[ ! -f android/key.properties ]]; then
  echo "✗ android/key.properties is missing: the build would be signed with"
  echo "  the debug key, which Google Play rejects."
  exit 1
fi

echo "→ flutter build appbundle --release"
flutter build appbundle --release

echo "$code" > .last_release_code
echo "✓ Ready: build/app/outputs/bundle/release/app-release.aab"
echo "  Now do the on-phone and Play Console steps in docs/RELEASE_CHECKLIST.md."
