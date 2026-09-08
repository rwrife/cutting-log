#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

source "$ROOT/tool/bootstrap.sh"

KEY_PROPS="$ROOT/android/key.properties"
if [[ -f "$KEY_PROPS" ]] && \
   grep -q '^storeFile=' "$KEY_PROPS" && \
   grep -q '^storePassword=' "$KEY_PROPS" && \
   grep -q '^keyAlias=' "$KEY_PROPS" && \
   grep -q '^keyPassword=' "$KEY_PROPS"; then
  echo "Android release signing: configured from android/key.properties"
else
  echo "Android release signing: not configured; using debug signing fallback for reproducible release builds"
fi

flutter build appbundle --release
flutter build apk --release

# Always publish a debug fallback artifact for reproducibility on unsigned hosts.
flutter build apk --debug

echo "Artifacts:"
for candidate in \
  build/app/outputs/bundle/release/app-release.aab \
  build/app/outputs/flutter-apk/app-release.apk \
  build/app/outputs/flutter-apk/app-debug.apk; do
  if [[ -f "$candidate" ]]; then
    echo "  - $candidate"
  fi
done
