#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

resolve_flutter_bin() {
  if command -v flutter >/dev/null 2>&1; then
    command -v flutter
    return 0
  fi

  if [[ -n "${FLUTTER_ROOT:-}" ]] && [[ -x "${FLUTTER_ROOT}/bin/flutter" ]]; then
    printf '%s\n' "${FLUTTER_ROOT}/bin/flutter"
    return 0
  fi

  mapfile -t candidates < <(compgen -G "$HOME/flutter-*/bin/flutter" || true)
  if [[ ${#candidates[@]} -gt 0 ]]; then
    printf '%s\n' "${candidates[@]}" | sort -V | tail -n1
    return 0
  fi

  return 1
}

FLUTTER_BIN="$(resolve_flutter_bin || true)"
if [[ -z "$FLUTTER_BIN" ]]; then
  cat >&2 <<'EOF'
Unable to find a Flutter binary.

Provide one of:
- flutter on PATH
- FLUTTER_ROOT env var pointing to an SDK root
- ~/flutter-*/bin/flutter
EOF
  exit 1
fi

export PATH="$(dirname "$FLUTTER_BIN"):$PATH"
DART_BIN="$(dirname "$FLUTTER_BIN")/dart"

expected="$(tr -d '[:space:]' < .flutter-version)"
actual="$($FLUTTER_BIN --version --machine | python3 -c 'import json,sys; print(json.load(sys.stdin)["frameworkVersion"])')"
if [[ "$actual" != "$expected" ]]; then
  printf 'Expected Flutter %s, found %s\n' "$expected" "$actual" >&2
  exit 1
fi

$FLUTTER_BIN --version
$DART_BIN --version
$FLUTTER_BIN pub get --enforce-lockfile
