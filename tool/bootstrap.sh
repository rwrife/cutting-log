#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

expected="$(tr -d '[:space:]' < .flutter-version)"
actual="$(flutter --version --machine | python3 -c 'import json,sys; print(json.load(sys.stdin)["frameworkVersion"])')"
if [[ "$actual" != "$expected" ]]; then
  printf 'Expected Flutter %s, found %s\n' "$expected" "$actual" >&2
  exit 1
fi

flutter --version
dart --version
flutter pub get --enforce-lockfile
