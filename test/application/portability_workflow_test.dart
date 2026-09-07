import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:cutting_log/src/application/portability_workflow.dart';
import 'package:cutting_log/src/data/app_database.dart';
import 'package:cutting_log/src/data/app_private_media_store.dart';
import 'package:cutting_log/src/data/drift_journal_repository.dart';
import 'package:cutting_log/src/domain/journal_entities.dart';
import 'package:cutting_log/src/platform/local_notification_gateway.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  test(
    'exports UTF-8 CSV and restores full library with media hashes',
    () async {
      final source = await _Harness.create('portability-source');
      final target = await _Harness.create('portability-target');
      addTearDown(() async {
        await source.dispose();
        await target.dispose();
      });

      await _seedFullLibrary(source);

      final export = await source.workflow.exportLibrary(includeMedia: true);

      expect(await export.archiveFile.exists(), isTrue);
      expect(
        await export.parentsCsv.readAsString(),
        startsWith('id,nickname,'),
      );
      expect(
        await export.cuttingsCsv.readAsString(),
        contains('started_at_utc'),
      );
      expect(
        await export.eventsCsv.readAsString(),
        contains('occurred_at_utc'),
      );
      expect(
        await export.remindersCsv.readAsString(),
        contains('scheduled_for_utc'),
      );
      expect(await export.eventsCsv.readAsString(), contains('Z'));

      final preview = await target.workflow.previewRestoreArchive(
        export.archiveFile,
      );
      expect(preview.totalConflicts, 0);
      expect(preview.totalAdditions, greaterThan(0));

      await target.workflow.applyRestorePreview(
        preview: preview,
        conflictPolicy: RestoreConflictPolicy.replaceExisting,
      );

      final parents = await target.repository.getParentPlants();
      final cuttings = await target.repository.getCuttings();
      final events = await target.repository.getCuttingEvents(
        EntityId('cutting-1'),
      );
      final media = await target.repository.getAllMediaAssets();
      final reminders = await target.repository.getReminders(
        EntityId('cutting-1'),
      );

      expect(parents.map((value) => value.id.value), contains('parent-1'));
      expect(cuttings.single.tags, <String>['north', 'water']);
      expect(events.map((value) => value.id.value), <String>[
        'event-1',
        'event-2',
      ]);
      expect(reminders.single.timeZoneId, 'America/Los_Angeles');

      final restoredAsset = media.single;
      final restoredFile = target.store.resolve(restoredAsset.relativePath);
      expect(await restoredFile.exists(), isTrue);
      final restoredHash = sha256
          .convert(await restoredFile.readAsBytes())
          .toString();
      expect(restoredHash, restoredAsset.sha256);
    },
  );

  test(
    'preview surfaces additions/conflicts and keepExisting skips conflicts',
    () async {
      final source = await _Harness.create('portability-preview-source');
      final target = await _Harness.create('portability-preview-target');
      addTearDown(() async {
        await source.dispose();
        await target.dispose();
      });

      final now = DateTime.utc(2026, 2, 1);
      await source.repository.createParentPlant(
        ParentPlant(
          id: EntityId('parent-shared'),
          nickname: 'Source Parent',
          createdAtUtc: now,
          updatedAtUtc: now,
        ),
      );
      await source.repository.createParentPlant(
        ParentPlant(
          id: EntityId('parent-new'),
          nickname: 'New Parent',
          createdAtUtc: now,
          updatedAtUtc: now,
        ),
      );

      await target.repository.createParentPlant(
        ParentPlant(
          id: EntityId('parent-shared'),
          nickname: 'Target Parent',
          createdAtUtc: now,
          updatedAtUtc: now,
        ),
      );

      final export = await source.workflow.exportLibrary(includeMedia: false);
      final preview = await target.workflow.previewRestoreArchive(
        export.archiveFile,
      );

      expect(preview.parents.conflicts, 1);
      expect(preview.parents.additions, 1);
      expect(preview.parents.potentialSkips, 1);

      final result = await target.workflow.applyRestorePreview(
        preview: preview,
        conflictPolicy: RestoreConflictPolicy.keepExisting,
      );

      final parents = await target.repository.getParentPlants();
      final shared = parents.firstWhere(
        (value) => value.id == EntityId('parent-shared'),
      );

      expect(result.skippedConflicts, preview.totalConflicts);
      expect(
        parents.map((value) => value.id.value),
        containsAll(<String>['parent-shared', 'parent-new']),
      );
      expect(shared.nickname, 'Target Parent');
    },
  );

  test('rejects unsafe traversal archive paths', () async {
    final harness = await _Harness.create('portability-unsafe');
    addTearDown(harness.dispose);

    final archive = Archive()
      ..addFile(ArchiveFile('../evil.txt', 1, Uint8List.fromList(<int>[1])));
    final bytes = ZipEncoder().encode(archive);
    final file = File('${harness.root.path}/unsafe.zip');
    await file.writeAsBytes(bytes, flush: true);

    await expectLater(
      () => harness.workflow.previewRestoreArchive(file),
      throwsA(
        isA<PortabilityException>().having(
          (error) => error.message,
          'message',
          contains('path'),
        ),
      ),
    );
  });

  test('hash mismatch backup fails without mutating target library', () async {
    final source = await _Harness.create('portability-hash-source');
    final target = await _Harness.create('portability-hash-target');
    addTearDown(() async {
      await source.dispose();
      await target.dispose();
    });

    await _seedFullLibrary(source);
    await target.repository.createParentPlant(
      ParentPlant(
        id: EntityId('existing-parent'),
        nickname: 'Existing',
        createdAtUtc: DateTime.utc(2026, 1, 1),
        updatedAtUtc: DateTime.utc(2026, 1, 1),
      ),
    );

    final export = await source.workflow.exportLibrary(includeMedia: true);
    final tampered = await _tamperOneMediaEntry(
      export.archiveFile,
      target.root,
    );
    final beforeParents = await target.repository.getParentPlants();

    await expectLater(
      () => target.workflow.previewRestoreArchive(tampered),
      throwsA(
        isA<PortabilityException>().having(
          (error) => error.message,
          'message',
          contains('hash mismatch'),
        ),
      ),
    );

    final afterParents = await target.repository.getParentPlants();
    expect(
      afterParents.map((value) => value.id),
      beforeParents.map((value) => value.id),
    );
  });

  test('restore transaction rolls back when apply hook throws', () async {
    final source = await _Harness.create('portability-rollback-source');
    final target = await _Harness.create(
      'portability-rollback-target',
      beforeApplyHook: () => throw StateError('forced rollback'),
    );
    addTearDown(() async {
      await source.dispose();
      await target.dispose();
    });

    await _seedFullLibrary(source);
    await target.repository.createParentPlant(
      ParentPlant(
        id: EntityId('existing-parent'),
        nickname: 'Keep me',
        createdAtUtc: DateTime.utc(2026, 2, 2),
        updatedAtUtc: DateTime.utc(2026, 2, 2),
      ),
    );

    final export = await source.workflow.exportLibrary(includeMedia: true);
    final preview = await target.workflow.previewRestoreArchive(
      export.archiveFile,
    );

    await expectLater(
      () => target.workflow.applyRestorePreview(
        preview: preview,
        conflictPolicy: RestoreConflictPolicy.replaceExisting,
      ),
      throwsA(isA<StateError>()),
    );

    final parents = await target.repository.getParentPlants();
    expect(parents, hasLength(1));
    expect(parents.single.nickname, 'Keep me');
    expect(await target.repository.getCuttings(), isEmpty);
  });

  test(
    'eraseLibrary clears database/media/cache and cancels reminders',
    () async {
      final harness = await _Harness.create('portability-erase');
      addTearDown(harness.dispose);

      await _seedFullLibrary(harness);
      final orphan = File('${harness.root.path}/media/originals/orphan.jpg')
        ..createSync(recursive: true)
        ..writeAsBytesSync(<int>[0x00, 0x01]);
      expect(await orphan.exists(), isTrue);
      final cacheFile = File('${harness.cache.path}/preview.tmp')
        ..createSync(recursive: true)
        ..writeAsStringSync('cached-data');

      final result = await harness.workflow.eraseLibrary();

      expect(result.parentsDeleted, greaterThan(0));
      expect(result.mediaFilesDeleted, greaterThan(0));
      expect(result.cacheEntriesDeleted, greaterThan(0));
      expect(result.notificationsCancelled, 1);
      expect(await harness.repository.getParentPlants(), isEmpty);
      expect(await harness.repository.getCuttings(), isEmpty);
      expect(await harness.repository.getAllMediaAssets(), isEmpty);
      expect((await harness.store.scanInventory()).files, isEmpty);
      expect(await cacheFile.exists(), isFalse);
      expect(harness.notifications.cancelled, contains('notif-1'));
    },
  );
}

Future<void> _seedFullLibrary(_Harness harness) async {
  final now = DateTime.utc(2026, 1, 1, 12);
  final parent = ParentPlant(
    id: EntityId('parent-1'),
    nickname: 'Monstera Mother',
    notes: 'Private note',
    createdAtUtc: now,
    updatedAtUtc: now,
  );
  await harness.repository.createParentPlant(parent);

  final cutting = Cutting(
    id: EntityId('cutting-1'),
    parentId: parent.id,
    name: 'Stem A',
    method: 'Stem',
    medium: 'Water',
    location: 'North window',
    tags: const <String>['Water', 'north'],
    startedAtUtc: now,
    createdAtUtc: now,
    updatedAtUtc: now,
  );

  final startEvent = CuttingEvent(
    id: EntityId('event-1'),
    cuttingId: cutting.id,
    occurredAtUtc: now,
    createdAtUtc: now,
    kind: CuttingEventKind.stage,
    stage: CuttingStage.started,
    note: 'Initial cut',
  );
  await harness.repository.createCuttingWithInitialEvent(cutting, startEvent);

  final laterEvent = CuttingEvent(
    id: EntityId('event-2'),
    cuttingId: cutting.id,
    occurredAtUtc: now.add(const Duration(days: 2)),
    createdAtUtc: now.add(const Duration(days: 2)),
    kind: CuttingEventKind.stage,
    stage: CuttingStage.rooting,
    note: 'Roots emerging',
  );
  await harness.repository.appendEvent(laterEvent);

  final imageSource = await _writePng(harness.root, 'seed.png');
  final imported = await harness.store.importImage(
    assetId: 'media-1',
    sourcePath: imageSource.path,
  );

  await harness.repository.addMediaAsset(
    MediaAsset(
      id: EntityId('media-1'),
      eventId: laterEvent.id,
      relativePath: imported.originalRelativePath,
      sha256: imported.sha256,
      mediaType: imported.mediaType,
      caption: 'Day two photo',
      importedAtUtc: now.add(const Duration(days: 2)),
    ),
  );

  await harness.repository.createReminder(
    Reminder(
      id: EntityId('reminder-1'),
      cuttingId: cutting.id,
      scheduledForUtc: now.add(const Duration(days: 7)),
      timeZoneId: 'America/Los_Angeles',
      status: ReminderStatus.pending,
      platformNotificationId: 'notif-1',
      createdAtUtc: now,
      updatedAtUtc: now,
    ),
  );
}

Future<File> _tamperOneMediaEntry(
  File archiveFile,
  Directory outputRoot,
) async {
  final sourceArchive = ZipDecoder().decodeBytes(
    await archiveFile.readAsBytes(),
  );
  final tamperedArchive = Archive();
  var replaced = false;

  for (final entry in sourceArchive.files) {
    final bytes = Uint8List.fromList(entry.content as List<int>);
    final payload = !replaced && entry.name.startsWith('media/')
        ? Uint8List.fromList(<int>[0xCA, 0xFE, 0xBA, 0xBE])
        : bytes;
    if (!replaced && entry.name.startsWith('media/')) {
      replaced = true;
    }
    tamperedArchive.addFile(ArchiveFile(entry.name, payload.length, payload));
  }

  if (!replaced) {
    throw StateError('missing media entry in backup archive');
  }

  final encoded = ZipEncoder().encode(tamperedArchive);
  final tampered = File('${outputRoot.path}/tampered-backup.zip');
  await tampered.writeAsBytes(encoded, flush: true);
  return tampered;
}

Future<File> _writePng(Directory root, String name) async {
  final file = File('${root.path}/$name');
  final image = img.Image(width: 48, height: 48);
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      image.setPixelRgba(x, y, 40 + (x % 80), 120 + (y % 80), 180, 255);
    }
  }
  await file.writeAsBytes(img.encodePng(image), flush: true);
  return file;
}

final class _Harness {
  _Harness._({
    required this.root,
    required this.cache,
    required this.database,
    required this.repository,
    required this.store,
    required this.notifications,
    required this.workflow,
  });

  final Directory root;
  final Directory cache;
  final AppDatabase database;
  final DriftJournalRepository repository;
  final AppPrivateMediaStore store;
  final _FakeNotifications notifications;
  final PortabilityWorkflow workflow;

  static Future<_Harness> create(
    String prefix, {
    void Function()? beforeApplyHook,
  }) async {
    final root = await Directory.systemTemp.createTemp('$prefix-root-');
    final cache = await Directory.systemTemp.createTemp('$prefix-cache-');
    final database = AppDatabase(NativeDatabase.memory(logStatements: false));
    final repository = DriftJournalRepository(database);
    final store = AppPrivateMediaStore(root);
    final notifications = _FakeNotifications();
    final workflow = PortabilityWorkflow(
      database,
      repository,
      store,
      notifications,
      exportDirectory: Directory('${root.path}/exports'),
      cacheDirectory: cache,
      clock: () => DateTime.utc(2026, 2, 1),
      beforeApplyHook: beforeApplyHook,
    );

    return _Harness._(
      root: root,
      cache: cache,
      database: database,
      repository: repository,
      store: store,
      notifications: notifications,
      workflow: workflow,
    );
  }

  Future<void> dispose() async {
    await database.close();
    if (await root.exists()) {
      await root.delete(recursive: true);
    }
    if (await cache.exists()) {
      await cache.delete(recursive: true);
    }
  }
}

final class _FakeNotifications implements LocalNotificationGateway {
  final List<String> cancelled = <String>[];

  @override
  Future<void> cancel(String platformId) async {
    cancelled.add(platformId);
  }

  @override
  Future<void> initialize() async {}

  @override
  Future<Set<String>> pendingIds() async => <String>{};

  @override
  Future<NotificationPermissionState> permissionState() async =>
      NotificationPermissionState.granted;

  @override
  Future<NotificationPermissionState> requestPermission() async =>
      NotificationPermissionState.granted;

  @override
  Future<void> schedule(Reminder reminder, String cuttingName) async {}
}
