import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('release-candidate scripts and docs are present', () {
    const requiredPaths = <String>[
      'tool/build_android_release.sh',
      'tool/release_candidate.sh',
      'android/key.properties.example',
      'docs/release-candidate-evidence.md',
      'docs/changelog.md',
      'docs/privacy-permissions-disclosure.md',
      'docs/migration-restore-notes.md',
      'docs/third-party-licenses.md',
      'docs/known-limitations.md',
      'docs/screenshot-evidence.md',
    ];

    for (final path in requiredPaths) {
      expect(File(path).existsSync(), isTrue, reason: '$path must exist');
    }
  });

  test('release docs preserve local-first and non-diagnostic boundaries', () {
    final privacy = File('docs/privacy-permissions-disclosure.md')
        .readAsStringSync();
    final limitations = File('docs/known-limitations.md').readAsStringSync();
    final checklist = File('docs/release-candidate-evidence.md')
        .readAsStringSync();

    expect(privacy, contains('No analytics'));
    expect(privacy, contains('offline'));
    expect(privacy, contains('Not requested: location'));

    expect(limitations, contains('does not diagnose'));
    expect(limitations, contains('does not')); // treatment/prediction sentence

    expect(checklist, contains('Optional permissions must remain in-context'));
    expect(
      checklist,
      contains('Keep local-first, account-free behavior intact'),
    );
  });
}
