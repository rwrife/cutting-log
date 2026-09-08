#!/usr/bin/env bash
set -u -o pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT_DIR="$ROOT/artifacts/release-candidate/$STAMP"
mkdir -p "$OUT_DIR"

REQUIRED_FAILURES=0

declare -A STEP_STATUS

audit_step() {
  local step_name="$1"
  local required="$2"
  shift 2

  local log_file="$OUT_DIR/${step_name}.log"
  local meta_file="$OUT_DIR/${step_name}.meta.txt"

  printf '== %s ==\n' "$step_name"
  if "$@" 2>&1 | tee "$log_file"; then
    STEP_STATUS["$step_name"]="ok"
    {
      printf 'required=%s\n' "$required"
      printf 'status=ok\n'
      printf 'exit_code=0\n'
      printf 'command=%q' "$1"
      shift
      for arg in "$@"; do printf ' %q' "$arg"; done
      printf '\n'
    } > "$meta_file"
    return 0
  else
    local rc=$?
    STEP_STATUS["$step_name"]="fail($rc)"
    {
      printf 'required=%s\n' "$required"
      printf 'status=fail\n'
      printf 'exit_code=%s\n' "$rc"
      printf 'command=%q' "$1"
      shift
      for arg in "$@"; do printf ' %q' "$arg"; done
      printf '\n'
    } > "$meta_file"

    if [[ "$required" == "required" ]]; then
      REQUIRED_FAILURES=$((REQUIRED_FAILURES + 1))
    fi

    return 0
  fi
}

# Core checks
 audit_step bootstrap required "$ROOT/tool/bootstrap.sh"
 audit_step quality required "$ROOT/tool/check.sh"
 audit_step android_debug required "$ROOT/tool/build_android.sh"
 audit_step android_release required "$ROOT/tool/build_android_release.sh"

if [[ "$(uname -s)" == "Darwin" ]]; then
  audit_step ios_simulator required "$ROOT/tool/build_ios.sh"
else
  STEP_STATUS["ios_simulator"]="skipped(non-darwin)"
  printf 'required=required\nstatus=skipped\nreason=non-darwin\n' \
    > "$OUT_DIR/ios_simulator.meta.txt"
fi

ARTIFACT_LIST="$OUT_DIR/artifact-files.txt"
CHECKSUM_LIST="$OUT_DIR/checksums.txt"
EXPORT_SCHEMA_HASH="$OUT_DIR/export-schema.sha256"

find "$ROOT/build" -type f \( -name '*.apk' -o -name '*.aab' -o -name '*.ipa' \) 2>/dev/null |
  sort > "$ARTIFACT_LIST"

if [[ -s "$ARTIFACT_LIST" ]]; then
  xargs -r sha256sum < "$ARTIFACT_LIST" > "$CHECKSUM_LIST"
else
  : > "$CHECKSUM_LIST"
fi

sha256sum "$ROOT/docs/export-schema-v1.json" > "$EXPORT_SCHEMA_HASH"
cat "$EXPORT_SCHEMA_HASH" >> "$CHECKSUM_LIST"

python3 - <<'PY' "$ROOT/pubspec.lock" > "$OUT_DIR/third-party-packages.txt"
import re
import sys

path = sys.argv[1]
name_re = re.compile(r'^\s{2}([^:]+):\s*$')
version_re = re.compile(r'^\s{4}version:\s+"?([^"\s]+)"?\s*$')

packages = []
current = None

with open(path, "r", encoding="utf-8") as fh:
    for line in fh:
        m_name = name_re.match(line)
        if m_name:
            current = {"name": m_name.group(1), "version": ""}
            packages.append(current)
            continue

        if current is None:
            continue

        m_version = version_re.match(line)
        if m_version:
            current["version"] = m_version.group(1)

for pkg in sorted(packages, key=lambda p: p["name"]):
    version = pkg["version"] or "unknown"
    print(f"{pkg['name']} {version}")
PY

cp "$ROOT/docs/export-schema-v1.json" "$OUT_DIR/"
cp "$ROOT/docs/release-candidate-evidence.md" "$OUT_DIR/"
cp "$ROOT/docs/privacy-permissions-disclosure.md" "$OUT_DIR/"
cp "$ROOT/docs/migration-restore-notes.md" "$OUT_DIR/"
cp "$ROOT/docs/third-party-licenses.md" "$OUT_DIR/"

SUMMARY="$OUT_DIR/summary.md"
{
  echo "# Release candidate summary"
  echo
  echo "- UTC timestamp: $STAMP"
  echo "- Git commit: $(git rev-parse HEAD)"
  echo
  echo "## Step results"
  for key in bootstrap quality android_debug android_release ios_simulator; do
    echo "- $key: ${STEP_STATUS[$key]:-unknown}"
  done
  echo
  echo "## Artifacts"
  if [[ -s "$ARTIFACT_LIST" ]]; then
    while IFS= read -r file; do
      echo "- ${file#$ROOT/}"
    done < "$ARTIFACT_LIST"
  else
    echo "- none produced in this run"
  fi
  echo
  echo "## Notes"
  echo "- Signed Android release requires android/key.properties (see android/key.properties.example)."
  echo "- iOS build evidence requires macOS + Xcode."
} > "$SUMMARY"

printf 'release_candidate_summary=%s\n' "$SUMMARY"

if [[ $REQUIRED_FAILURES -gt 0 ]]; then
  printf 'release_candidate_status=failed required_failures=%s\n' "$REQUIRED_FAILURES" >&2
  exit 1
fi

echo "release_candidate_status=ok"
