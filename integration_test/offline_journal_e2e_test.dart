// Device/simulator end-to-end journey for the release-candidate checklist.
//
// Drives the REAL app (lib/main.dart wiring: Drift file database, app-private
// media store, portability workflows) against production code paths on an
// Android emulator or physical device. Requires a fresh-install state; the
// runbook (docs/e2e-runbook.md) clears app data before each run.
//
// This automation is NOT a substitute for the manual TalkBack/VoiceOver
// walkthroughs in docs/release-candidate-evidence.md. It records that the
// full parent -> cutting -> timeline -> reminder -> photo-denial -> export ->
// erase -> restore round-trip works on built software and captures
// screenshots from the running app.

import 'dart:io';

import 'package:cutting_log/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('fresh install: full journal journey with restore round-trip', (
    tester,
  ) async {
    // ignore: unawaited_futures
    app.main();
    await tester.pumpAndSettle();

    // 1. Journal shell is up on a fresh install with the offline promise.
    expect(find.text('Cutting Log'), findsOneWidget);
    expect(
      find.textContaining('Stored privately on this device'),
      findsOneWidget,
    );
    await _scrollTo(tester, find.text('Offline and account-free'));
    await _screenshot(tester, '01-fresh-install');

    // 2. Create a parent plant.
    await _enterText(tester, 'Parent plant nickname', 'E2E pothos');
    await _tapVisible(tester, find.byKey(const ValueKey('create-parent')));
    await tester.pumpAndSettle();
    expect(find.text('Cuttings for E2E pothos'), findsOneWidget);

    // 3. Start a cutting with a first observation.
    await _enterText(tester, 'Unique cutting name', 'E2E node A');
    await _enterText(tester, 'Method', 'Stem');
    await _enterText(tester, 'Medium (optional)', 'Water');
    await _tapVisible(tester, find.byKey(const ValueKey('start-cutting')));
    await tester.pumpAndSettle();
    expect(find.text('E2E node A timeline'), findsOneWidget);

    await _enterText(
      tester,
      'New observation',
      'E2E: node placed in water at the north window.',
    );
    await _tapVisible(tester, find.byKey(const ValueKey('add-observation')));
    await tester.pumpAndSettle();
    expect(find.textContaining('E2E: node placed in water'), findsOneWidget);
    await _screenshot(tester, '02-timeline-with-observation');

    // 4. Photo step: exercise the optional-permission contract on the real
    // platform. Denial must be handled gracefully and the journal must stay
    // usable; granting (emulator virtual camera) must attach the photo.
    await _enterText(tester, 'Photo caption (optional)', 'E2E caption');
    final photoMenu = find.text('Add photo (optional)');
    await _scrollTo(tester, photoMenu);
    await tester.tap(photoMenu);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Use camera'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    final deniedBanner = find.textContaining('Permission denied');
    final attachedBanner = find.textContaining(
      'Photo attached to the latest timeline event',
    );
    expect(
      deniedBanner.evaluate().isNotEmpty ||
          attachedBanner.evaluate().isNotEmpty,
      isTrue,
      reason:
          'Expected either a permission-denied notice or a successful '
          'photo attach on the platform.',
    );
    // In every outcome the journal remains usable.
    expect(find.byKey(const ValueKey('add-observation')), findsOneWidget);
    await _screenshot(tester, '03-photo-permission-handled');

    // 5. Schedule an in-app check-in (notifications optional, in-app list
    // must hold the reminder even without notification permission).
    await _scrollTo(tester, find.byKey(const ValueKey('add-check-in')));
    await tester.tap(find.byKey(const ValueKey('add-check-in')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.textContaining('check-in'), findsWidgets);
    await _screenshot(tester, '04-check-in-scheduled');

    // 6. Export a full local backup and capture the produced path.
    await _scrollTo(tester, find.byKey(const ValueKey('export-backup')));
    await tester.tap(find.byKey(const ValueKey('export-backup')));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    final exportPath = _latestExportPathFrom(tester);
    expect(exportPath, isNotNull, reason: 'Export must report its path.');
    expect(File(exportPath!).existsSync(), isTrue);
    await _screenshot(tester, '05-export-complete');

    // 7. Erase the entire local library via the explicit confirmation flow.
    await _scrollTo(tester, find.text('Delete full local library'));
    await tester.tap(find.text('Delete full local library'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete local library'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(
      find.text('No active parent plants yet. Create one below.'),
      findsOneWidget,
    );
    await _screenshot(tester, '06-library-erased');

    // 8. Restore the exported archive: preview first, then apply.
    await _enterText(tester, 'Restore archive path (.zip)', exportPath);
    await _scrollTo(tester, find.byKey(const ValueKey('preview-restore')));
    await tester.tap(find.byKey(const ValueKey('preview-restore')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Restore preview'), findsOneWidget);
    await _screenshot(tester, '07-restore-preview');

    await tester.tap(find.byKey(const ValueKey('apply-restore')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apply restore'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.textContaining('Restore complete'), findsOneWidget);

    // 9. The restored journal shows the original lineage again.
    await _scrollTo(tester, find.text('Parent plants'));
    expect(find.text('E2E pothos'), findsOneWidget);
    await _screenshot(tester, '08-restored-journal');
  });
}

Future<void> _enterText(WidgetTester tester, String label, String value) async {
  final field = find.widgetWithText(TextField, label);
  await _scrollTo(tester, field);
  await tester.enterText(field, value);
  await tester.pumpAndSettle();
}

Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await _scrollTo(tester, finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _screenshot(WidgetTester tester, String name) async {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  await binding.takeScreenshot(name);
}

/// Reads the `Latest export: <path>` line rendered after an export.
String? _latestExportPathFrom(WidgetTester tester) {
  for (final element in find.byType(SelectableText).evaluate()) {
    final widget = element.widget as SelectableText;
    final text = widget.data ?? '';
    if (text.startsWith('Latest export: ')) {
      return text.substring('Latest export: '.length).trim();
    }
  }
  return null;
}
