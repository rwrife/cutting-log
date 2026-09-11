// Device/simulator end-to-end journey for the release-candidate checklist.
//
// Drives the REAL app (lib/main.dart wiring: Drift file database, app-private
// media store, portability workflows) against production code paths on an
// Android emulator or iOS simulator. Requires a fresh-install state; the
// runbook (docs/e2e-runbook.md) clears app data before each run. CI executes
// this journey automatically on named runners:
//   - Android: `android-e2e` job, API 34 google_apis x86_64 emulator
//     (GitHub ubuntu-latest, KVM-accelerated hosted runners).
//   - iOS: `ios-e2e` job, booted iPhone simulator on macos-15.
//
// Deterministic on-device contract (journey mode):
//   - The journey calls `JourneyConfiguration.enableForIntegrationTest()`
//     before `app.main()`. main.dart then swaps exactly three capability
//     entry points that would otherwise open native UI an instrumented test
//     cannot answer: the notification permission prompt is deferred to the
//     current state, optional permission requests report granted without
//     opening settings (Android runners additionally `pm grant` them), and
//     photo import returns a synthetic PNG file instead of opening the
//     system picker.
//   - Everything else runs for real: Drift file database, app-private media
//     store copy + thumbnail generation, reminder persistence with stored
//     time zones, ZIP/CSV export, complete erase, and restore round-trip.
//   - Production builds never set the flag, so shipped behavior (real
//     prompts, real picker) is unchanged and covered by widget tests and
//     the manual walkthroughs.
//   - Every step is recorded in `journey-summary.json` inside the app's
//     documents directory plus PNG screenshots written from takeScreenshot
//     bytes where the platform produces them. CI copies both out as build
//     artifacts. No claim in this file depends on fabricated output.
//
// This automation is NOT a substitute for the manual TalkBack/VoiceOver
// walkthroughs in docs/release-candidate-evidence.md.

import 'dart:convert';
import 'dart:io';

import 'package:cutting_log/main.dart' as app;
import 'package:cutting_log/src/platform/journey_configuration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

void main() {
  // Must be set before app.main() is invoked (in the test body below):
  // main.dart reads this flag once while wiring platform gateways.
  JourneyConfiguration.enableForIntegrationTest();
  final driver = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final steps = <String, Object?>{};
  Directory? evidenceRoot;

  void record(String step, Object outcome) {
    steps[step] = outcome;
    // Stream progress to the CI console so a stall is attributable to a
    // specific step instead of 40 silent minutes.
    // ignore: avoid_print
    print('JOURNEY step=$step outcome=$outcome');
  }

  tearDownAll(() async {
    final root = evidenceRoot;
    if (root != null) {
      final summary = <String, Object?>{
        'journey': 'offline_journal_e2e',
        'platform': Platform.operatingSystem,
        'finishedAtUtc': DateTime.now().toUtc().toIso8601String(),
        'steps': steps,
      };
      try {
        final file = File(p.join(root.path, 'journey-summary.json'));
        await file.writeAsString(
          const JsonEncoder.withIndent('  ').convert(summary),
        );
        // ignore: avoid_print
        print('Wrote journey summary to ${file.path}');
      } catch (error) {
        // ignore: avoid_print
        print('Could not write journey summary: $error');
      }
    }
    // Completion signaling is automatic: the binding's own tearDownAll
    // reports `allTestsFinished` to the native runner even when a step
    // failed, so a failing journey exits instead of hanging the job.
    // ignore: avoid_print
    print('JOURNEY teardown complete (${steps.length} steps recorded)');
  });

  testWidgets(
    'fresh install: full journal journey with restore round-trip',
    timeout: const Timeout(Duration(minutes: 15)),
    (tester) async {
      evidenceRoot = (await getApplicationDocumentsDirectory()).createTempSync(
        'e2e-evidence-',
      );

      // Android takeScreenshot requires the surface to be converted to an
      // image view first (platform limitation of the integration_test plugin).
      var surfaceConverted = false;
      if (Platform.isAndroid) {
        try {
          await driver.convertFlutterSurfaceToImage();
          await tester.pump(const Duration(milliseconds: 200));
          surfaceConverted = true;
        } catch (error) {
          record('androidSurfaceConversion', 'failed: $error');
        }
      }

      final startClock = DateTime.now();
      // ignore: unawaited_futures
      app.main();

      // 1. Journal shell is up on a fresh install with the offline promise.
      // Cold starts on CI runners perform real async work before the first
      // frame (opening the Drift file database, reconciling reminders), which
      // can take several seconds on a debug build. pumpAndSettle returns as
      // soon as no frames are scheduled — that is NOT a startup barrier, so
      // wait on the rendered shell itself (first CI run failed exactly here).
      final shellUp = await _waitFor(
        tester,
        find.text('Cutting Log'),
        maxSeconds: 90,
      );
      expect(
        shellUp,
        isTrue,
        reason: 'App shell must render on fresh install.',
      );
      record(
        'startupWallClockMs',
        DateTime.now().difference(startClock).inMilliseconds,
      );
      final bannerVisible = await _waitFor(
        tester,
        find.textContaining('Stored privately on this device'),
        maxSeconds: 20,
      );
      expect(
        bannerVisible,
        isTrue,
        reason: 'Offline promise banner must render.',
      );
      record('freshInstallShell', true);
      // The 'Offline and account-free' status tile exists only in the
      // repository-less overview variant; the real app renders the
      // privacy banner instead (verified in this journey above). Scroll
      // to the section anchors that the real shell renders and assert
      // against those.
      await _scrollTo(tester, find.text('Parent plants'));
      await _screenshot(
        tester,
        driver,
        evidenceRoot,
        '01-fresh-install',
        enabled: !Platform.isAndroid || surfaceConverted,
      );
      record(
        'offlineBannerVisible',
        find
            .textContaining('No account, network, or optional permission')
            .evaluate()
            .isNotEmpty,
      );

      // 2. Create a parent plant.
      await _enterText(tester, 'Parent plant nickname', 'E2E pothos');
      await _tapVisible(tester, find.byKey(const ValueKey('create-parent')));
      await tester.pumpAndSettle();
      expect(find.text('Cuttings for E2E pothos'), findsOneWidget);
      record('createParent', true);

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
      record('cuttingTimelineObservation', true);
      await _screenshot(
        tester,
        driver,
        evidenceRoot,
        '02-timeline-with-observation',
        enabled: !Platform.isAndroid || surfaceConverted,
      );

      // 4. Photo step: exercise the real attach pipeline end to end. In
      // journey mode the gateway hands back a synthetic PNG file instead of
      // opening the native picker, but everything downstream is the production
      // path: permission check, app-private store copy, thumbnail generation,
      // media record, and timeline rendering. The manual walkthrough still
      // covers the native picker and camera UX.
      await _enterText(tester, 'Photo caption (optional)', 'E2E caption');
      final photoMenu = find.text('Add photo (optional)');
      await _scrollTo(tester, photoMenu);
      await tester.tap(photoMenu);
      await tester.pumpAndSettle();
      expect(find.text('From photo library'), findsOneWidget);
      expect(find.text('Use camera'), findsOneWidget);
      record('photoMenuAccessible', true);
      await _screenshot(
        tester,
        driver,
        evidenceRoot,
        '03-photo-menu',
        enabled: !Platform.isAndroid || surfaceConverted,
      );
      await tester.tap(find.text('From photo library'));
      final attached = await _waitFor(
        tester,
        find.textContaining('Photo attached to the latest timeline event'),
        maxSeconds: 30,
      );
      expect(attached, isTrue, reason: 'Journey-mode attach must complete.');
      record('photoAttached', true);
      final photoVisible = await _waitFor(
        tester,
        find.textContaining('E2E caption'),
        maxSeconds: 20,
      );
      record('timelinePhotoRendered', photoVisible);
      expect(photoVisible, isTrue);
      // The journal remains usable and crash-free.
      expect(find.byKey(const ValueKey('add-observation')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await _screenshot(
        tester,
        driver,
        evidenceRoot,
        '04-photo-attached',
        enabled: !Platform.isAndroid || surfaceConverted,
      );

      // 5. Schedule an in-app check-in. In journey mode the notification
      // permission prompt is deferred (never shown), so creation completes on
      // every platform and the reminder row must appear. Whether a platform
      // notification id was also scheduled is recorded as an OS difference
      // (Android with pre-granted POST_NOTIFICATIONS schedules; iOS simulator
      // typically reports denied and keeps the reminder in-app only).
      await _scrollTo(tester, find.byKey(const ValueKey('add-check-in')));
      await tester.tap(find.byKey(const ValueKey('add-check-in')));
      await tester.pumpAndSettle();
      expect(find.text('Save'), findsOneWidget);
      await tester.tap(find.text('Save'));
      final reminderRowVisible = await _waitFor(
        tester,
        find.textContaining('Upcoming check-in'),
        maxSeconds: 20,
      );
      expect(reminderRowVisible, isTrue, reason: 'Check-in must be stored.');
      record('reminderRowVisible', true);
      final inAppOnly = find
          .textContaining('In-app only; notifications unavailable')
          .evaluate()
          .isNotEmpty;
      record('reminderPlatformNotificationScheduled', !inAppOnly);
      // The journal stays usable.
      expect(find.byKey(const ValueKey('add-observation')), findsOneWidget);
      await _screenshot(
        tester,
        driver,
        evidenceRoot,
        '05-check-in-step',
        enabled: !Platform.isAndroid || surfaceConverted,
      );

      // 6. Export a full local backup and capture the produced path.
      await _scrollTo(tester, find.byKey(const ValueKey('export-backup')));
      await tester.tap(find.byKey(const ValueKey('export-backup')));
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      final exportVisible = await _waitFor(
        tester,
        find.textContaining('Latest export: '),
        maxSeconds: 40,
      );
      expect(exportVisible, isTrue, reason: 'Export must report its path.');
      final exportPath = _latestExportPathFrom(tester);
      expect(exportPath, isNotNull);
      expect(File(exportPath!).existsSync(), isTrue);
      record('exportPath', exportPath);
      record('exportFileExists', true);
      await _screenshot(
        tester,
        driver,
        evidenceRoot,
        '06-export-complete',
        enabled: !Platform.isAndroid || surfaceConverted,
      );

      // 7. Erase the entire local library via the explicit confirmation flow.
      await _scrollTo(tester, find.text('Delete full local library'));
      await tester.tap(find.text('Delete full local library'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete local library'));
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      final erased = await _waitFor(
        tester,
        find.text('No active parent plants yet. Create one below.'),
        maxSeconds: 20,
      );
      expect(erased, isTrue, reason: 'Erase must empty the journal.');
      record('libraryErased', true);
      await _screenshot(
        tester,
        driver,
        evidenceRoot,
        '07-library-erased',
        enabled: !Platform.isAndroid || surfaceConverted,
      );

      // 8. Restore the exported archive: preview first, then apply.
      await _enterText(tester, 'Restore archive path (.zip)', exportPath);
      await _scrollTo(tester, find.byKey(const ValueKey('preview-restore')));
      await tester.tap(find.byKey(const ValueKey('preview-restore')));
      await tester.pumpAndSettle();
      final previewed = await _waitFor(
        tester,
        find.textContaining('Restore preview'),
        maxSeconds: 20,
      );
      expect(previewed, isTrue);
      record('restorePreviewed', true);
      await _screenshot(
        tester,
        driver,
        evidenceRoot,
        '08-restore-preview',
        enabled: !Platform.isAndroid || surfaceConverted,
      );

      await tester.tap(find.byKey(const ValueKey('apply-restore')));
      await tester.pumpAndSettle();
      // The confirmation dialog's button shares the 'Apply restore' label;
      // the dialog is the last route, so its button is the last match.
      await tester.tap(find.widgetWithText(FilledButton, 'Apply restore').last);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      final restored = await _waitFor(
        tester,
        find.textContaining('Restore complete'),
        maxSeconds: 20,
      );
      expect(restored, isTrue);
      record('restoreApplied', true);

      // 9. The restored journal shows the original lineage again.
      await _scrollTo(tester, find.text('Parent plants'));
      expect(find.text('E2E pothos'), findsOneWidget);
      record('restoredLineageVisible', true);
      await _screenshot(
        tester,
        driver,
        evidenceRoot,
        '09-restored-journal',
        enabled: !Platform.isAndroid || surfaceConverted,
      );
    },
  );
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

/// Waits up to [maxSeconds] of wall-clock time for [finder] to match,
/// pumping the tree between real sleeps so background async work (database,
/// media processing) keeps progressing on the device's real event loop.
Future<bool> _waitFor(
  WidgetTester tester,
  Finder finder, {
  required int maxSeconds,
}) async {
  final deadline = DateTime.now().add(Duration(seconds: maxSeconds));
  while (DateTime.now().isBefore(deadline)) {
    if (finder.evaluate().isNotEmpty) return true;
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
  }
  return finder.evaluate().isNotEmpty;
}

/// Captures a screenshot into the on-device evidence directory when the
/// platform can produce bytes; records the outcome instead of failing the
/// journey when it cannot (iOS `flutter test` does not return bytes).
Future<void> _screenshot(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding driver,
  Directory? evidenceRoot,
  String name, {
  required bool enabled,
}) async {
  final root = evidenceRoot;
  if (!enabled || root == null) {
    return;
  }
  try {
    final bytes = await driver.takeScreenshot(name);
    final file = File(p.join(root.path, '$name.png'));
    await file.writeAsBytes(bytes);
  } catch (error) {
    // Screenshot capture is evidence tooling, not a product behavior:
    // record and continue. The live screencap loop in CI still captures
    // real frames from the device framebuffer.
    debugPrint('screenshot $name unavailable on this platform: $error');
  }
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
