# Third-party software inventory and licensing

This repository is MIT-licensed. Runtime and developer dependencies are declared in `pubspec.yaml` and pinned in `pubspec.lock`.

## Runtime packages

- archive
- crypto
- drift
- flutter_local_notifications
- image
- image_picker
- permission_handler
- timezone
- path
- path_provider

## Developer packages

- build_runner
- drift_dev
- flutter_lints
- flutter_test
- sqlite3

## License verification process

Release-candidate evidence generation (`tool/release_candidate.sh`) exports a pinned package inventory file:

- `artifacts/release-candidate/<stamp>/third-party-packages.txt`

For each package in that file, verify the published license text from the package source used by `pubspec.lock` before final release tagging.

## Notes

- Do not add analytics or ad SDK dependencies without explicit approved scope.
- Optional permissions must remain in-context and user initiated.
