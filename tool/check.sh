#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
source "$ROOT/tool/bootstrap.sh"

DESTINATION="${IOS_TEST_DESTINATION:-}"
if [[ -z "$DESTINATION" ]]; then
  # Ask the selected Xcode which devices this scheme can actually run on.
  # Runner images change their installed runtimes and iPhone models over time.
  destinations="$(xcodebuild -project ios/Runner.xcodeproj -scheme Runner -showdestinations)"
  device_id="$(printf '%s\n' "$destinations" | sed -nE '/platform:iOS Simulator.*name:iPhone/ s/.*id:([^,}]+).*/\1/p' | head -1 | tr -d ' ')"
  if [[ -z "$device_id" ]]; then
    echo 'No compatible iPhone simulator is available for the selected Xcode.' >&2
    printf '%s\n' "$destinations" >&2
    exit 2
  fi
  DESTINATION="platform=iOS Simulator,id=$device_id"
fi
echo "Testing on $DESTINATION"
xcodebuild \
  -project ios/Runner.xcodeproj \
  -scheme Runner \
  -destination "$DESTINATION" \
  -derivedDataPath build/DerivedData \
  CODE_SIGNING_ALLOWED=NO \
  clean test
