#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [[ "$(uname -s)" != Darwin ]]; then
  echo 'The iOS simulator build requires macOS with Xcode.' >&2
  exit 2
fi

"$ROOT/tool/bootstrap.sh"
xcodebuild -version
flutter build ios --simulator --debug --no-codesign
