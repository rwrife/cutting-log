#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
source "$ROOT/tool/bootstrap.sh"

xcodebuild \
  -project ios/Runner.xcodeproj \
  -scheme Runner \
  -sdk iphonesimulator \
  -configuration Debug \
  -derivedDataPath build/DerivedData \
  CODE_SIGNING_ALLOWED=NO \
  build
