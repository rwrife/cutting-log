#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != Darwin ]]; then
  echo 'Cutting Log requires macOS with Xcode 16 or newer.' >&2
  exit 2
fi

xcodebuild -version
