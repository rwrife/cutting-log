#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
source "$ROOT/tool/bootstrap.sh"

DESTINATION="${IOS_TEST_DESTINATION:-platform=iOS Simulator,name=iPhone 16 Pro}"
xcodebuild \
  -project ios/Runner.xcodeproj \
  -scheme Runner \
  -destination "$DESTINATION" \
  -derivedDataPath build/DerivedData \
  CODE_SIGNING_ALLOWED=NO \
  clean test
