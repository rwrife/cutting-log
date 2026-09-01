#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

"$ROOT/tool/bootstrap.sh"
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test --reporter expanded
