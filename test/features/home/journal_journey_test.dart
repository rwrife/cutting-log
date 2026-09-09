import 'dart:io';

import 'package:cutting_log/src/application/capture_workflow.dart';
import 'package:cutting_log/src/application/media_workflow.dart';
import 'package:cutting_log/src/application/portability_workflow.dart';
import 'package:cutting_log/src/application/reminder_workflow.dart';
import 'package:cutting_log/src/data/app_database.dart';
import 'package:cutting_log/src/data/app_private_media_store.dart';
import 'package:cutting_log/src/data/drift_journal_repository.dart';
import 'package:cutting_log/src/domain/journal_entities.dart';
import 'package:cutting_log/src/platform/local_notification_gateway.dart';
import 'package:cutting_log/src/platform/optional_permission_gateway.dart';
import 'package:cutting_log/src/platform/photo_import_gateway.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

/// Full release-candidate acceptance journey on the real persistence stack:
/// Drift file database + app-private media store + versioned ZIP backup.
///
/// Covers the automatable half of the issue #7 checklist on a headless host:
/// parent -> cutting -> timeline -> timezone-safe reminder -> photo attach
/// including a mid-flow optional-permission denial -> export -> complete
/// erase -> restore round-trip. Screen-reader walkthroughs, airplane mode,
/// and OS-level permission revocation remain manual per
/// docs/release-candidate-evidence.md and docs/e2e-runbook.md.
void main() {
  late Directory storageRoot;
  late AppDatabase database;
  late DriftJournalRepository repository;
  late AppPrivateMediaStore mediaStore;
  late MediaWorkflow mediaWorkflow;
  late PortabilityWorkflow portabilityWorkflow;
  late _ToggleablePermissionGateway permissions;
  late _FakePhotoGateway photoGateway;
  late CaptureWorkflow capture;

  setUp(() async {
    storageRoot = await Directory.systemTemp.createTemp('cutting-log-journey-');
    database = AppDatabase(
      NativeDatabase(File('${storageRoot.path}/journal.sqlite')),
    );
    repository = DriftJournalRepository(database);
    mediaStore = AppPrivateMediaStore(storageRoot);
    permissions = _ToggleablePermissionGateway();
    photoGateway = _FakePhotoGateway();
    mediaWorkflow = MediaWorkflow(
      repository,
      permissions,
      photoGateway,
      mediaStore,
    );
    portabilityWorkflow = PortabilityWorkflow(
      database,
      repository,
      mediaStore,
      const DisabledLocalNotificationGateway(),
      exportDirectory: Directory('${storageRoot.path}/exports'),
      cacheDirectory: Directory('${storageRoot.path}/cache'),
    );
    capture = CaptureWorkflow(repository);
  });

  tearDown(() async {
    await database.close();
    if (await storageRoot.exists()) {
      await storageRoot.delete(recursive: true);
    }
  });

  test('journey: capture, photo attach, denied permission, export, '
      'complete erase, and restore round-trip on the file database', () async {
    final parent = await capture.createParent(nickname: 'Journey pothos');
    final cutting = await capture.startCutting(
      parentId: parent.id,
      name: 'Journey node',
      method: 'Stem',
      startedAtUtc: DateTime.now().toUtc(),
      medium: 'Water',
      initialNote: 'First node observation',
    );

    final eventsAfterCapture = await repository.getCuttingEvents(cutting.id);
    expect(
      eventsAfterCapture,
      isNotEmpty,
      reason: 'Starting a cutting with a note must seed the timeline.',
    );

    // Photo step 1: granted permission stores bytes in app-private media.
    permissions.allow = true;
    final sourcePhoto = await _writePickedPhoto(storageRoot);
    photoGateway.next = sourcePhoto;
    final observationEvent = eventsAfterCapture.last;
    final attachment = await mediaWorkflow.attachPhotoToEvent(
      eventId: observationEvent.id,
      source: PhotoImportSource.photoLibrary,
      caption: 'Roots visible',
    );
    expect(attachment, isNotNull);
    final assets = await repository.getAllMediaAssets();
    expect(assets, hasLength(1));
    expect(
      mediaStore.resolve(assets.single.relativePath).existsSync(),
      isTrue,
      reason: 'Photo bytes must live in the app-private media store.',
    );

    // Photo step 2: denial aborts the import without creating records and
    // the journal stays fully usable.
    permissions.allow = false;
    photoGateway.next = sourcePhoto;
    await expectLater(
      mediaWorkflow.attachPhotoToEvent(
        eventId: observationEvent.id,
        source: PhotoImportSource.photoLibrary,
      ),
      throwsA(isA<MediaPermissionDeniedException>()),
    );
    expect(photoGateway.callCount, 1, reason: 'Pick skipped when denied.');
    expect(await repository.getAllMediaAssets(), hasLength(1));
    final journalStillReadable = await repository.getParentPlants();
    expect(journalStillReadable, hasLength(1));

    // Export the full library (ZIP + CSVs) from the real file database.
    final export = await portabilityWorkflow.exportLibrary();
    expect(File(export.archiveFile.path).existsSync(), isTrue);
    expect(File(export.manifestFile.path).existsSync(), isTrue);
    for (final csv in <File>[
      export.parentsCsv,
      export.cuttingsCsv,
      export.eventsCsv,
      export.remindersCsv,
    ]) {
      expect(File(csv.path).existsSync(), isTrue);
    }

    // Complete erase via the production portability workflow.
    final erased = await portabilityWorkflow.eraseLibrary();
    expect(erased.parentsDeleted, greaterThan(0));
    expect(await repository.getParentPlants(), isEmpty);
    expect(await repository.getAllMediaAssets(), isEmpty);

    // Restore the exported archive after preview/apply.
    final preview = await portabilityWorkflow.previewRestoreArchive(
      File(export.archiveFile.path),
    );
    expect(preview.totalAdditions, greaterThan(0));
    final applied = await portabilityWorkflow.applyRestorePreview(
      preview: preview,
      conflictPolicy: RestoreConflictPolicy.keepExisting,
    );
    expect(applied.appliedParents, greaterThan(0));
    expect(applied.appliedCuttings, greaterThan(0));
    expect(applied.appliedEvents, greaterThan(0));
    expect(applied.appliedMediaAssets, greaterThan(0));

    final restoredParents = await repository.getParentPlants();
    final restoredCuttings = await repository.getCuttings(
      parentId: restoredParents.single.id,
    );
    final restoredEvents = await repository.getCuttingEvents(
      restoredCuttings.single.id,
    );
    final restoredMedia = await repository.getAllMediaAssets();
    expect(restoredCuttings, hasLength(1));
    expect(restoredEvents.length, eventsAfterCapture.length);
    expect(restoredMedia, hasLength(1));
    expect(
      mediaStore.resolve(restoredMedia.single.relativePath).existsSync(),
      isTrue,
      reason: 'Restored media bytes must be present in private storage.',
    );
  });

  test('check-in wall clock round-trips through the stored timezone', () {
    final now = DateTime.now().toUtc().add(const Duration(days: 3));
    for (final zone in <String>[
      'UTC',
      'America/Los_Angeles',
      'America/New_York',
      'Europe/London',
      'Australia/Sydney',
    ]) {
      final utc = ReminderWorkflow.resolveWallClock(
        year: now.year,
        month: now.month,
        day: now.day,
        hour: 9,
        minute: 30,
        timeZoneId: zone,
      );
      final back = ReminderWorkflow.wallClockFor(utc, zone);
      expect(
        <int>[back.year, back.month, back.day, back.hour, back.minute],
        <int>[now.year, now.month, now.day, 9, 30],
        reason: '$zone wall clock must render identically on any host zone.',
      );
    }
  });

  test(
    'scheduled check-in persists with its timezone and pending status',
    () async {
      final parent = await capture.createParent(nickname: 'Reminder parent');
      final cutting = await capture.startCutting(
        parentId: parent.id,
        name: 'Reminder cutting',
        method: 'Stem',
        startedAtUtc: DateTime.now().toUtc(),
      );
      await repository.createReminder(
        Reminder(
          id: EntityId('reminder-journey'),
          cuttingId: cutting.id,
          scheduledForUtc: DateTime.now().toUtc().add(const Duration(days: 1)),
          timeZoneId: 'Europe/London',
          status: ReminderStatus.pending,
          createdAtUtc: DateTime.now().toUtc(),
          updatedAtUtc: DateTime.now().toUtc(),
        ),
      );

      final reminders = await repository.getReminders(cutting.id);
      expect(reminders.single.timeZoneId, 'Europe/London');
      expect(reminders.single.status, ReminderStatus.pending);
    },
  );
}

class _ToggleablePermissionGateway implements OptionalPermissionGateway {
  bool allow = true;

  @override
  Future<bool> request(OptionalPermission permission) async => allow;
}

class _FakePhotoGateway implements PhotoImportGateway {
  PickedPhoto? next;
  int callCount = 0;

  @override
  Future<PickedPhoto?> pick(PhotoImportSource source) async {
    callCount += 1;
    final photo = next;
    if (photo == null) return null;
    return PickedPhoto(
      path: photo.path,
      source: source,
      pickedAtUtc: photo.pickedAtUtc,
    );
  }
}

Future<PickedPhoto> _writePickedPhoto(Directory root) async {
  final imageFile = File('${root.path}/source-photo.png');
  final image = img.Image(width: 48, height: 48);
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      image.setPixelRgba(x, y, 50, 120 + (x % 40), 180 + (y % 40), 255);
    }
  }
  await imageFile.writeAsBytes(img.encodePng(image), flush: true);
  return PickedPhoto(
    path: imageFile.path,
    source: PhotoImportSource.photoLibrary,
    pickedAtUtc: DateTime.now().toUtc(),
  );
}
