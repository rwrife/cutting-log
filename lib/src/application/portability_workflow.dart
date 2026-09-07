import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:cutting_log/src/data/app_database.dart';
import 'package:cutting_log/src/data/app_private_media_store.dart';
import 'package:cutting_log/src/domain/journal_data_repository.dart';
import 'package:cutting_log/src/domain/journal_entities.dart';
import 'package:cutting_log/src/platform/local_notification_gateway.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as path;

final class PortabilityException implements Exception {
  const PortabilityException(this.message);

  final String message;

  @override
  String toString() => 'PortabilityException: $message';
}

enum RestoreConflictPolicy { keepExisting, replaceExisting, failOnConflict }

final class PortabilityLimits {
  const PortabilityLimits({
    this.maxArchiveBytes = 64 * 1024 * 1024,
    this.maxUncompressedBytes = 128 * 1024 * 1024,
    this.maxEntryBytes = 16 * 1024 * 1024,
    this.maxEntries = 2000,
  });

  final int maxArchiveBytes;
  final int maxUncompressedBytes;
  final int maxEntryBytes;
  final int maxEntries;
}

final class PortabilityExportResult {
  const PortabilityExportResult({
    required this.archiveFile,
    required this.manifestFile,
    required this.parentsCsv,
    required this.cuttingsCsv,
    required this.eventsCsv,
    required this.remindersCsv,
    required this.createdAtUtc,
    required this.includeMedia,
    required this.parentCount,
    required this.cuttingCount,
    required this.eventCount,
    required this.mediaCount,
    required this.reminderCount,
  });

  final File archiveFile;
  final File manifestFile;
  final File parentsCsv;
  final File cuttingsCsv;
  final File eventsCsv;
  final File remindersCsv;
  final DateTime createdAtUtc;
  final bool includeMedia;
  final int parentCount;
  final int cuttingCount;
  final int eventCount;
  final int mediaCount;
  final int reminderCount;
}

final class RestoreEntityPreview {
  const RestoreEntityPreview({
    required this.additions,
    required this.conflicts,
    required this.potentialSkips,
  });

  final int additions;
  final int conflicts;
  final int potentialSkips;
}

final class RestorePreview {
  const RestorePreview._({
    required this.parents,
    required this.cuttings,
    required this.events,
    required this.mediaAssets,
    required this.reminders,
    required this.backupIncludesMedia,
    required this.createdAtUtc,
    required this._parsed,
  });

  final RestoreEntityPreview parents;
  final RestoreEntityPreview cuttings;
  final RestoreEntityPreview events;
  final RestoreEntityPreview mediaAssets;
  final RestoreEntityPreview reminders;
  final bool backupIncludesMedia;
  final DateTime createdAtUtc;
  final _ParsedBackup _parsed;

  int get totalConflicts =>
      parents.conflicts +
      cuttings.conflicts +
      events.conflicts +
      mediaAssets.conflicts +
      reminders.conflicts;

  int get totalAdditions =>
      parents.additions +
      cuttings.additions +
      events.additions +
      mediaAssets.additions +
      reminders.additions;
}

final class RestoreApplyResult {
  const RestoreApplyResult({
    required this.policy,
    required this.appliedParents,
    required this.appliedCuttings,
    required this.appliedEvents,
    required this.appliedMediaAssets,
    required this.appliedReminders,
    required this.skippedConflicts,
  });

  final RestoreConflictPolicy policy;
  final int appliedParents;
  final int appliedCuttings;
  final int appliedEvents;
  final int appliedMediaAssets;
  final int appliedReminders;
  final int skippedConflicts;
}

final class EraseLibraryResult {
  const EraseLibraryResult({
    required this.parentsDeleted,
    required this.cuttingsDeleted,
    required this.eventsDeleted,
    required this.mediaAssetsDeleted,
    required this.remindersDeleted,
    required this.mediaFilesDeleted,
    required this.cacheEntriesDeleted,
    required this.notificationsCancelled,
  });

  final int parentsDeleted;
  final int cuttingsDeleted;
  final int eventsDeleted;
  final int mediaAssetsDeleted;
  final int remindersDeleted;
  final int mediaFilesDeleted;
  final int cacheEntriesDeleted;
  final int notificationsCancelled;
}

final class PortabilityWorkflow {
  PortabilityWorkflow(
    this._database,
    this._repository,
    this._mediaStore,
    this._notifications, {
    required this.exportDirectory,
    required this.cacheDirectory,
    this.limits = const PortabilityLimits(),
    DateTime Function()? clock,
    this.beforeApplyHook,
  }) : _clock = clock ?? _defaultClock;

  final AppDatabase _database;
  final JournalDataRepository _repository;
  final OwnedMediaStore _mediaStore;
  final LocalNotificationGateway _notifications;
  final Directory exportDirectory;
  final Directory cacheDirectory;
  final PortabilityLimits limits;
  final DateTime Function() _clock;
  final void Function()? beforeApplyHook;

  Future<PortabilityExportResult> exportLibrary({
    bool includeMedia = true,
  }) async {
    final now = _clock().toUtc();
    final snapshot = await _collectSnapshot(now);
    await exportDirectory.create(recursive: true);

    final stem = _timestampStem(now);
    final parentsCsvContent = _parentsCsv(snapshot.parents);
    final cuttingsCsvContent = _cuttingsCsv(snapshot.cuttings);
    final eventsCsvContent = _eventsCsv(snapshot.events);
    final remindersCsvContent = _remindersCsv(snapshot.reminders);

    final parentsCsv = File(
      path.join(exportDirectory.path, '$stem-parents.csv'),
    );
    final cuttingsCsv = File(
      path.join(exportDirectory.path, '$stem-cuttings.csv'),
    );
    final eventsCsv = File(path.join(exportDirectory.path, '$stem-events.csv'));
    final remindersCsv = File(
      path.join(exportDirectory.path, '$stem-reminders.csv'),
    );

    await parentsCsv.writeAsString(parentsCsvContent, flush: true);
    await cuttingsCsv.writeAsString(cuttingsCsvContent, flush: true);
    await eventsCsv.writeAsString(eventsCsvContent, flush: true);
    await remindersCsv.writeAsString(remindersCsvContent, flush: true);

    final journalJsonContent = _journalJson(snapshot);
    final schemaJsonContent = _backupSchemaJson;
    final mediaArchiveEntries = includeMedia
        ? await _collectMediaArchiveEntries(snapshot.mediaAssets)
        : const <_MediaArchiveEntry>[];

    final fileEntries = <String, Uint8List>{
      'journal.json': Uint8List.fromList(utf8.encode(journalJsonContent)),
      'schema/backup-schema-v1.json': Uint8List.fromList(
        utf8.encode(schemaJsonContent),
      ),
      'csv/parents.csv': Uint8List.fromList(utf8.encode(parentsCsvContent)),
      'csv/cuttings.csv': Uint8List.fromList(utf8.encode(cuttingsCsvContent)),
      'csv/events.csv': Uint8List.fromList(utf8.encode(eventsCsvContent)),
      'csv/reminders.csv': Uint8List.fromList(utf8.encode(remindersCsvContent)),
    };

    for (final media in mediaArchiveEntries) {
      fileEntries[media.archivePath] = media.bytes;
    }

    final manifest = <String, Object?>{
      'format': 'cutting-log-backup',
      'version': 1,
      'createdAtUtc': _iso(now),
      'appSchemaVersion': _database.schemaVersion,
      'includeMedia': includeMedia,
      'limits': <String, Object?>{
        'maxArchiveBytes': limits.maxArchiveBytes,
        'maxUncompressedBytes': limits.maxUncompressedBytes,
        'maxEntryBytes': limits.maxEntryBytes,
        'maxEntries': limits.maxEntries,
      },
      'fileHashes': <String, Object?>{
        for (final entry in fileEntries.entries)
          entry.key: sha256.convert(entry.value).toString(),
      },
      'media': mediaArchiveEntries
          .map(
            (entry) => <String, Object?>{
              'relativePath': entry.relativePath,
              'archivePath': entry.archivePath,
              'sha256': entry.sha256,
              'bytes': entry.bytes.length,
            },
          )
          .toList(growable: false),
    };

    final manifestContent = _canonicalJson(manifest);
    final manifestFile = File(
      path.join(exportDirectory.path, '$stem-manifest.json'),
    );
    await manifestFile.writeAsString(manifestContent, flush: true);

    final archive = Archive();
    archive.addFile(
      ArchiveFile(
        'manifest.json',
        manifestContent.length,
        utf8.encode(manifestContent),
      ),
    );
    for (final entry in fileEntries.entries) {
      archive.addFile(
        ArchiveFile(entry.key, entry.value.length, entry.value.toList()),
      );
    }
    final zipped = ZipEncoder().encode(archive);
    final archiveFile = File(
      path.join(exportDirectory.path, '$stem-backup.zip'),
    );
    await archiveFile.writeAsBytes(zipped, flush: true);

    return PortabilityExportResult(
      archiveFile: archiveFile,
      manifestFile: manifestFile,
      parentsCsv: parentsCsv,
      cuttingsCsv: cuttingsCsv,
      eventsCsv: eventsCsv,
      remindersCsv: remindersCsv,
      createdAtUtc: now,
      includeMedia: includeMedia,
      parentCount: snapshot.parents.length,
      cuttingCount: snapshot.cuttings.length,
      eventCount: snapshot.events.length,
      mediaCount: snapshot.mediaAssets.length,
      reminderCount: snapshot.reminders.length,
    );
  }

  Future<RestorePreview> previewRestoreArchive(File archiveFile) async {
    final parsed = await _parseBackupArchive(archiveFile);
    final existing = await _loadExistingIds();

    RestoreEntityPreview previewFor(
      Iterable<String> incoming,
      Set<String> current,
    ) {
      var additions = 0;
      var conflicts = 0;
      for (final id in incoming) {
        if (current.contains(id)) {
          conflicts += 1;
        } else {
          additions += 1;
        }
      }
      return RestoreEntityPreview(
        additions: additions,
        conflicts: conflicts,
        potentialSkips: conflicts,
      );
    }

    return RestorePreview._(
      parents: previewFor(
        parsed.snapshot.parents.map((value) => value.id.value),
        existing.parents,
      ),
      cuttings: previewFor(
        parsed.snapshot.cuttings.map((value) => value.id.value),
        existing.cuttings,
      ),
      events: previewFor(
        parsed.snapshot.events.map((value) => value.id.value),
        existing.events,
      ),
      mediaAssets: previewFor(
        parsed.snapshot.mediaAssets.map((value) => value.id.value),
        existing.mediaAssets,
      ),
      reminders: previewFor(
        parsed.snapshot.reminders.map((value) => value.id.value),
        existing.reminders,
      ),
      backupIncludesMedia: parsed.includeMedia,
      createdAtUtc: parsed.createdAtUtc,
      parsed: parsed,
    );
  }

  Future<RestoreApplyResult> applyRestorePreview({
    required RestorePreview preview,
    required RestoreConflictPolicy conflictPolicy,
  }) async {
    if (conflictPolicy == RestoreConflictPolicy.failOnConflict &&
        preview.totalConflicts > 0) {
      throw PortabilityException(
        'restore blocked: archive conflicts with ${preview.totalConflicts} existing record IDs',
      );
    }

    final parsed = preview._parsed;
    final existing = await _loadExistingIds();
    final toWriteMedia = _mediaWritesForPolicy(
      parsed,
      existing,
      conflictPolicy,
    );
    await _ensureWritableMediaTargets(toWriteMedia, conflictPolicy);

    final stagedMediaDirectory = await Directory(
      path.join(
        cacheDirectory.path,
        'restore-staging-${DateTime.now().microsecondsSinceEpoch}',
      ),
    ).create(recursive: true);

    try {
      for (final media in toWriteMedia) {
        final stagedFile = File(
          path.join(stagedMediaDirectory.path, media.relativePath),
        );
        await stagedFile.parent.create(recursive: true);
        await stagedFile.writeAsBytes(media.bytes, flush: true);
      }

      var appliedParents = 0;
      var appliedCuttings = 0;
      var appliedEvents = 0;
      var appliedMediaAssets = 0;
      var appliedReminders = 0;
      var skippedConflicts = 0;

      await _database.transaction(() async {
        if (conflictPolicy == RestoreConflictPolicy.replaceExisting) {
          await _cancelPendingReminderNotifications();
          await _clearLibraryRows();
        }

        beforeApplyHook?.call();

        appliedParents = await _insertParents(
          parsed.snapshot.parents,
          existing,
          conflictPolicy,
        );
        appliedCuttings = await _insertCuttings(
          parsed.snapshot.cuttings,
          existing,
          conflictPolicy,
        );
        appliedEvents = await _insertEvents(
          parsed.snapshot.events,
          existing,
          conflictPolicy,
        );
        appliedReminders = await _insertReminders(
          parsed.snapshot.reminders,
          existing,
          conflictPolicy,
        );
        appliedMediaAssets = await _insertMediaAssets(
          parsed.snapshot.mediaAssets,
          existing,
          conflictPolicy,
        );

        skippedConflicts =
            preview.totalConflicts -
            (conflictPolicy == RestoreConflictPolicy.replaceExisting
                ? preview.totalConflicts
                : 0);
      });

      if (conflictPolicy == RestoreConflictPolicy.replaceExisting) {
        await _clearAllManagedMediaFiles();
      }

      for (final media in toWriteMedia) {
        final stagedFile = File(
          path.join(stagedMediaDirectory.path, media.relativePath),
        );
        final target = _mediaStore.resolve(media.relativePath);
        await target.parent.create(recursive: true);
        if (await target.exists()) {
          await target.delete();
        }
        await stagedFile.copy(target.path);
      }

      return RestoreApplyResult(
        policy: conflictPolicy,
        appliedParents: appliedParents,
        appliedCuttings: appliedCuttings,
        appliedEvents: appliedEvents,
        appliedMediaAssets: appliedMediaAssets,
        appliedReminders: appliedReminders,
        skippedConflicts: skippedConflicts,
      );
    } finally {
      if (await stagedMediaDirectory.exists()) {
        await stagedMediaDirectory.delete(recursive: true);
      }
    }
  }

  Future<RestoreApplyResult> restoreArchive({
    required File archiveFile,
    required RestoreConflictPolicy conflictPolicy,
  }) async {
    final preview = await previewRestoreArchive(archiveFile);
    return applyRestorePreview(
      preview: preview,
      conflictPolicy: conflictPolicy,
    );
  }

  Future<EraseLibraryResult> eraseLibrary() async {
    final snapshot = await _collectSnapshot(_clock().toUtc());
    final notificationsCancelled = await _cancelPendingReminderNotifications();

    await _database.transaction(() async {
      await _clearLibraryRows();
    });

    final mediaFilesDeleted = await _clearAllManagedMediaFiles();
    final cacheEntriesDeleted = await _clearCacheDirectoryEntries();

    return EraseLibraryResult(
      parentsDeleted: snapshot.parents.length,
      cuttingsDeleted: snapshot.cuttings.length,
      eventsDeleted: snapshot.events.length,
      mediaAssetsDeleted: snapshot.mediaAssets.length,
      remindersDeleted: snapshot.reminders.length,
      mediaFilesDeleted: mediaFilesDeleted,
      cacheEntriesDeleted: cacheEntriesDeleted,
      notificationsCancelled: notificationsCancelled,
    );
  }

  Future<_LibrarySnapshot> _collectSnapshot(DateTime nowUtc) async {
    final parents = await _repository.getParentPlants()
      ..sort((left, right) => left.id.compareTo(right.id));
    final cuttings = await _repository.getCuttings()
      ..sort((left, right) => left.id.compareTo(right.id));

    final events = <CuttingEvent>[];
    final reminders = <Reminder>[];
    for (final cutting in cuttings) {
      events.addAll(await _repository.getCuttingEvents(cutting.id));
      reminders.addAll(await _repository.getReminders(cutting.id));
    }
    events.sort(_compareEventsByIdentity);
    reminders.sort((left, right) => left.id.compareTo(right.id));

    final mediaAssets = <MediaAsset>[];
    for (final event in events) {
      mediaAssets.addAll(await _repository.getMediaAssets(event.id));
    }
    mediaAssets.sort((left, right) => left.id.compareTo(right.id));

    return _LibrarySnapshot(
      exportedAtUtc: nowUtc,
      parents: parents,
      cuttings: cuttings,
      events: events,
      mediaAssets: mediaAssets,
      reminders: reminders,
    );
  }

  Future<List<_MediaArchiveEntry>> _collectMediaArchiveEntries(
    List<MediaAsset> assets,
  ) async {
    final entries = <_MediaArchiveEntry>[];
    final seen = <String>{};
    for (final asset in assets) {
      if (!seen.add(asset.relativePath)) {
        continue;
      }
      final file = _mediaStore.resolve(asset.relativePath);
      if (!await file.exists()) {
        throw PortabilityException(
          'media asset is referenced but missing from local storage: ${asset.relativePath}',
        );
      }
      final bytes = await file.readAsBytes();
      final hash = sha256.convert(bytes).toString();
      if (hash != asset.sha256) {
        throw PortabilityException(
          'media hash mismatch for ${asset.relativePath}; expected ${asset.sha256}',
        );
      }
      entries.add(
        _MediaArchiveEntry(
          relativePath: asset.relativePath,
          archivePath: 'media/${asset.relativePath}',
          sha256: hash,
          bytes: bytes,
        ),
      );
    }
    entries.sort(
      (left, right) => left.relativePath.compareTo(right.relativePath),
    );
    return entries;
  }

  Future<_ParsedBackup> _parseBackupArchive(File archiveFile) async {
    if (!await archiveFile.exists()) {
      throw const PortabilityException('backup archive does not exist');
    }
    final compressedBytes = await archiveFile.readAsBytes();
    if (compressedBytes.length > limits.maxArchiveBytes) {
      throw PortabilityException(
        'archive exceeds ${limits.maxArchiveBytes} compressed bytes',
      );
    }

    Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(compressedBytes, verify: true);
    } on Object {
      throw const PortabilityException('failed to decode backup ZIP archive');
    }

    if (archive.files.length > limits.maxEntries) {
      throw PortabilityException('archive has too many entries');
    }

    final extracted = <String, Uint8List>{};
    var totalUncompressedBytes = 0;

    for (final entry in archive) {
      final name = entry.name;
      _validateArchivePath(name);

      if (entry.isSymbolicLink) {
        throw PortabilityException(
          'archive contains forbidden symlink entry: $name',
        );
      }
      if (!entry.isFile) {
        continue;
      }
      if (extracted.containsKey(name)) {
        throw PortabilityException('archive contains duplicate entry: $name');
      }

      final bytes = Uint8List.fromList(entry.content as List<int>);
      if (bytes.length > limits.maxEntryBytes) {
        throw PortabilityException('archive entry exceeds limit: $name');
      }
      totalUncompressedBytes += bytes.length;
      if (totalUncompressedBytes > limits.maxUncompressedBytes) {
        throw const PortabilityException(
          'archive exceeds uncompressed safety limit',
        );
      }
      extracted[name] = bytes;
    }

    final manifestBytes = extracted['manifest.json'];
    final journalBytes = extracted['journal.json'];
    if (manifestBytes == null || journalBytes == null) {
      throw const PortabilityException(
        'archive must include manifest.json and journal.json',
      );
    }

    final manifest = _asMap(_decodeJsonUtf8(manifestBytes, 'manifest.json'));
    final format = _requireString(manifest, 'format');
    if (format != 'cutting-log-backup') {
      throw PortabilityException('unsupported backup format: $format');
    }
    final version = _requireInt(manifest, 'version');
    if (version != 1) {
      throw PortabilityException('unsupported backup version: $version');
    }
    final includeMedia = _requireBool(manifest, 'includeMedia');
    final createdAtUtc = _parseUtc(
      _requireString(manifest, 'createdAtUtc'),
      'manifest.createdAtUtc',
    );

    final fileHashesValue = manifest['fileHashes'];
    final fileHashes = _asMap(fileHashesValue, 'manifest.fileHashes');
    for (final entry in fileHashes.entries) {
      final filePath = entry.key;
      final expectedHash = entry.value;
      if (expectedHash is! String) {
        throw const PortabilityException(
          'manifest file hash values must be strings',
        );
      }
      final bytes = extracted[filePath];
      if (bytes == null) {
        throw PortabilityException(
          'manifest references missing archive file: $filePath',
        );
      }
      final actualHash = sha256.convert(bytes).toString();
      if (actualHash != expectedHash) {
        throw PortabilityException('hash mismatch for archive file: $filePath');
      }
    }

    final snapshot = _parseSnapshot(journalBytes);
    final mediaByRelativePath = <String, _BackupMediaFile>{};
    final mediaEntriesRaw = manifest['media'];
    final mediaEntries = _asList(mediaEntriesRaw, 'manifest.media');
    for (final value in mediaEntries) {
      final item = _asMap(value, 'manifest.media[]');
      final relativePath = _requireString(item, 'relativePath');
      final archivePath = _requireString(item, 'archivePath');
      final expectedSha256 = _requireString(item, 'sha256');

      final bytes = extracted[archivePath];
      if (bytes == null) {
        throw PortabilityException(
          'media payload missing from archive: $archivePath',
        );
      }
      final actualHash = sha256.convert(bytes).toString();
      if (actualHash != expectedSha256) {
        throw PortabilityException('media hash mismatch for $relativePath');
      }
      mediaByRelativePath[relativePath] = _BackupMediaFile(
        relativePath: relativePath,
        bytes: bytes,
      );
    }

    _validateRelationships(snapshot);

    for (final asset in snapshot.mediaAssets) {
      if (includeMedia) {
        final media = mediaByRelativePath[asset.relativePath];
        if (media == null) {
          throw PortabilityException(
            'backup is missing referenced media: ${asset.relativePath}',
          );
        }
        final payloadHash = sha256.convert(media.bytes).toString();
        if (payloadHash != asset.sha256) {
          throw PortabilityException(
            'backup media does not match metadata hash for ${asset.relativePath}',
          );
        }
      }
    }

    return _ParsedBackup(
      createdAtUtc: createdAtUtc,
      includeMedia: includeMedia,
      snapshot: snapshot,
      mediaByRelativePath: mediaByRelativePath,
    );
  }

  _LibrarySnapshot _parseSnapshot(Uint8List journalBytes) {
    final decoded = _decodeJsonUtf8(journalBytes, 'journal.json');
    final map = _asMap(decoded);
    final version = _requireInt(map, 'version');
    if (version != 1) {
      throw PortabilityException(
        'unsupported journal schema version: $version',
      );
    }

    final parents =
        _asList(map['parents'], 'journal.parents')
            .map((value) => _parseParent(_asMap(value, 'journal.parents[]')))
            .toList(growable: false)
          ..sort((left, right) => left.id.compareTo(right.id));

    final cuttings =
        _asList(map['cuttings'], 'journal.cuttings')
            .map((value) => _parseCutting(_asMap(value, 'journal.cuttings[]')))
            .toList(growable: false)
          ..sort((left, right) => left.id.compareTo(right.id));

    final events =
        _asList(map['events'], 'journal.events')
            .map((value) => _parseEvent(_asMap(value, 'journal.events[]')))
            .toList(growable: false)
          ..sort(_compareEventsByIdentity);

    final mediaAssets =
        _asList(map['mediaAssets'], 'journal.mediaAssets')
            .map(
              (value) =>
                  _parseMediaAsset(_asMap(value, 'journal.mediaAssets[]')),
            )
            .toList(growable: false)
          ..sort((left, right) => left.id.compareTo(right.id));

    final reminders =
        _asList(map['reminders'], 'journal.reminders')
            .map(
              (value) => _parseReminder(_asMap(value, 'journal.reminders[]')),
            )
            .toList(growable: false)
          ..sort((left, right) => left.id.compareTo(right.id));

    return _LibrarySnapshot(
      exportedAtUtc: _parseUtc(
        _requireString(map, 'exportedAtUtc'),
        'journal.exportedAtUtc',
      ),
      parents: parents,
      cuttings: cuttings,
      events: events,
      mediaAssets: mediaAssets,
      reminders: reminders,
    );
  }

  ParentPlant _parseParent(Map<String, Object?> map) => ParentPlant(
    id: EntityId(_requireString(map, 'id')),
    nickname: _requireString(map, 'nickname'),
    speciesText: _optionalString(map, 'speciesText'),
    notes: _requireString(map, 'notes'),
    createdAtUtc: _parseUtc(
      _requireString(map, 'createdAtUtc'),
      'parent.createdAtUtc',
    ),
    updatedAtUtc: _parseUtc(
      _requireString(map, 'updatedAtUtc'),
      'parent.updatedAtUtc',
    ),
    archivedAtUtc: _optionalUtc(map, 'archivedAtUtc'),
  );

  Cutting _parseCutting(Map<String, Object?> map) {
    final tags = _asList(map['tags'], 'cutting.tags')
        .map((value) {
          if (value is! String) {
            throw const PortabilityException('cutting tags must be strings');
          }
          return value;
        })
        .toList(growable: false);
    return Cutting(
      id: EntityId(_requireString(map, 'id')),
      parentId: EntityId(_requireString(map, 'parentId')),
      name: _requireString(map, 'name'),
      method: _requireString(map, 'method'),
      medium: _requireString(map, 'medium'),
      location: _requireString(map, 'location'),
      tags: tags,
      startedAtUtc: _parseUtc(
        _requireString(map, 'startedAtUtc'),
        'cutting.startedAtUtc',
      ),
      createdAtUtc: _parseUtc(
        _requireString(map, 'createdAtUtc'),
        'cutting.createdAtUtc',
      ),
      updatedAtUtc: _parseUtc(
        _requireString(map, 'updatedAtUtc'),
        'cutting.updatedAtUtc',
      ),
      archivedAtUtc: _optionalUtc(map, 'archivedAtUtc'),
    );
  }

  CuttingEvent _parseEvent(Map<String, Object?> map) => CuttingEvent(
    id: EntityId(_requireString(map, 'id')),
    cuttingId: EntityId(_requireString(map, 'cuttingId')),
    occurredAtUtc: _parseUtc(
      _requireString(map, 'occurredAtUtc'),
      'event.occurredAtUtc',
    ),
    createdAtUtc: _parseUtc(
      _requireString(map, 'createdAtUtc'),
      'event.createdAtUtc',
    ),
    kind: CuttingEventKind.values.byName(_requireString(map, 'kind')),
    note: _requireString(map, 'note'),
    stage: _optionalString(map, 'stage') == null
        ? null
        : CuttingStage.values.byName(_requireString(map, 'stage')),
    outcome: _optionalString(map, 'outcome') == null
        ? null
        : CuttingOutcome.values.byName(_requireString(map, 'outcome')),
    correctsEventId: _optionalString(map, 'correctsEventId') == null
        ? null
        : EntityId(_requireString(map, 'correctsEventId')),
  );

  MediaAsset _parseMediaAsset(Map<String, Object?> map) => MediaAsset(
    id: EntityId(_requireString(map, 'id')),
    eventId: EntityId(_requireString(map, 'eventId')),
    relativePath: _requireString(map, 'relativePath'),
    sha256: _requireString(map, 'sha256'),
    mediaType: _requireString(map, 'mediaType'),
    caption: _requireString(map, 'caption'),
    capturedAtUtc: _optionalUtc(map, 'capturedAtUtc'),
    importedAtUtc: _parseUtc(
      _requireString(map, 'importedAtUtc'),
      'mediaAsset.importedAtUtc',
    ),
  );

  Reminder _parseReminder(Map<String, Object?> map) => Reminder(
    id: EntityId(_requireString(map, 'id')),
    cuttingId: EntityId(_requireString(map, 'cuttingId')),
    scheduledForUtc: _parseUtc(
      _requireString(map, 'scheduledForUtc'),
      'reminder.scheduledForUtc',
    ),
    timeZoneId: _requireString(map, 'timeZoneId'),
    status: ReminderStatus.values.byName(_requireString(map, 'status')),
    platformNotificationId: _optionalString(map, 'platformNotificationId'),
    createdAtUtc: _parseUtc(
      _requireString(map, 'createdAtUtc'),
      'reminder.createdAtUtc',
    ),
    updatedAtUtc: _parseUtc(
      _requireString(map, 'updatedAtUtc'),
      'reminder.updatedAtUtc',
    ),
    completedAtUtc: _optionalUtc(map, 'completedAtUtc'),
    snoozedFromUtc: _optionalUtc(map, 'snoozedFromUtc'),
  );

  void _validateRelationships(_LibrarySnapshot snapshot) {
    void ensureUnique(String label, Iterable<String> values) {
      final seen = <String>{};
      for (final value in values) {
        if (!seen.add(value)) {
          throw PortabilityException('duplicate $label ID in backup: $value');
        }
      }
    }

    ensureUnique('parent', snapshot.parents.map((value) => value.id.value));
    ensureUnique('cutting', snapshot.cuttings.map((value) => value.id.value));
    ensureUnique('event', snapshot.events.map((value) => value.id.value));
    ensureUnique('media', snapshot.mediaAssets.map((value) => value.id.value));
    ensureUnique('reminder', snapshot.reminders.map((value) => value.id.value));

    final parentIds = snapshot.parents.map((value) => value.id).toSet();
    final cuttingById = {
      for (final value in snapshot.cuttings) value.id: value,
    };
    final eventsById = {for (final value in snapshot.events) value.id: value};

    for (final cutting in snapshot.cuttings) {
      if (!parentIds.contains(cutting.parentId)) {
        throw PortabilityException(
          'cutting references missing parent: ${cutting.id.value} -> ${cutting.parentId.value}',
        );
      }
    }

    final eventsByCutting = <EntityId, List<CuttingEvent>>{};
    for (final event in snapshot.events) {
      if (!cuttingById.containsKey(event.cuttingId)) {
        throw PortabilityException(
          'event references missing cutting: ${event.id.value} -> ${event.cuttingId.value}',
        );
      }
      eventsByCutting
          .putIfAbsent(event.cuttingId, () => <CuttingEvent>[])
          .add(event);
    }
    for (final group in eventsByCutting.values) {
      deriveCuttingState(group);
    }

    for (final media in snapshot.mediaAssets) {
      final event = eventsById[media.eventId];
      if (event == null) {
        throw PortabilityException(
          'media references missing event: ${media.id.value} -> ${media.eventId.value}',
        );
      }
      if (media.importedAtUtc.isBefore(event.createdAtUtc)) {
        throw PortabilityException(
          'media importedAtUtc is earlier than event creation: ${media.id.value}',
        );
      }
    }

    for (final reminder in snapshot.reminders) {
      if (!cuttingById.containsKey(reminder.cuttingId)) {
        throw PortabilityException(
          'reminder references missing cutting: ${reminder.id.value} -> ${reminder.cuttingId.value}',
        );
      }
    }
  }

  Future<_ExistingIds> _loadExistingIds() async {
    final parents = await (_database.select(_database.parentPlants)).get();
    final cuttings = await (_database.select(_database.cuttings)).get();
    final events = await (_database.select(_database.cuttingEvents)).get();
    final mediaAssets = await (_database.select(_database.mediaAssets)).get();
    final reminders = await (_database.select(_database.reminders)).get();

    return _ExistingIds(
      parents: {for (final row in parents) row.id},
      cuttings: {for (final row in cuttings) row.id},
      events: {for (final row in events) row.id},
      mediaAssets: {for (final row in mediaAssets) row.id},
      reminders: {for (final row in reminders) row.id},
    );
  }

  List<_BackupMediaFile> _mediaWritesForPolicy(
    _ParsedBackup parsed,
    _ExistingIds existing,
    RestoreConflictPolicy policy,
  ) {
    if (!parsed.includeMedia) {
      return const <_BackupMediaFile>[];
    }

    if (policy == RestoreConflictPolicy.replaceExisting) {
      return parsed.mediaByRelativePath.values.toList(
        growable: false,
      )..sort((left, right) => left.relativePath.compareTo(right.relativePath));
    }

    final writes = <_BackupMediaFile>[];
    for (final asset in parsed.snapshot.mediaAssets) {
      if (existing.mediaAssets.contains(asset.id.value)) {
        continue;
      }
      final media = parsed.mediaByRelativePath[asset.relativePath];
      if (media == null) {
        throw PortabilityException(
          'backup is missing media payload for ${asset.relativePath}',
        );
      }
      writes.add(media);
    }

    writes.sort(
      (left, right) => left.relativePath.compareTo(right.relativePath),
    );
    return writes;
  }

  Future<void> _ensureWritableMediaTargets(
    List<_BackupMediaFile> writes,
    RestoreConflictPolicy policy,
  ) async {
    if (policy == RestoreConflictPolicy.replaceExisting) {
      return;
    }
    for (final media in writes) {
      if (await _mediaStore.exists(media.relativePath)) {
        throw PortabilityException(
          'restore would overwrite existing local media file without replace policy: ${media.relativePath}',
        );
      }
    }
  }

  Future<int> _insertParents(
    List<ParentPlant> parents,
    _ExistingIds existing,
    RestoreConflictPolicy policy,
  ) async {
    var applied = 0;
    for (final parent in parents) {
      final exists = existing.parents.contains(parent.id.value);
      if (exists && policy == RestoreConflictPolicy.keepExisting) {
        continue;
      }
      await _database
          .into(_database.parentPlants)
          .insert(
            ParentPlantsCompanion.insert(
              id: parent.id.value,
              nickname: parent.nickname,
              speciesText: Value<String?>(parent.speciesText),
              notes: Value<String>(parent.notes),
              createdAtUtc: parent.createdAtUtc,
              updatedAtUtc: parent.updatedAtUtc,
              archivedAtUtc: Value<DateTime?>(parent.archivedAtUtc),
            ),
            mode: InsertMode.insertOrReplace,
          );
      applied += 1;
    }
    return applied;
  }

  Future<int> _insertCuttings(
    List<Cutting> cuttings,
    _ExistingIds existing,
    RestoreConflictPolicy policy,
  ) async {
    var applied = 0;
    for (final cutting in cuttings) {
      final exists = existing.cuttings.contains(cutting.id.value);
      if (exists && policy == RestoreConflictPolicy.keepExisting) {
        continue;
      }
      await _database
          .into(_database.cuttings)
          .insert(
            CuttingsCompanion.insert(
              id: cutting.id.value,
              parentId: cutting.parentId.value,
              name: cutting.name,
              method: cutting.method,
              medium: Value<String>(cutting.medium),
              location: Value<String>(cutting.location),
              startedAtUtc: cutting.startedAtUtc,
              createdAtUtc: cutting.createdAtUtc,
              updatedAtUtc: cutting.updatedAtUtc,
              archivedAtUtc: Value<DateTime?>(cutting.archivedAtUtc),
            ),
            mode: InsertMode.insertOrReplace,
          );

      await (_database.delete(
        _database.cuttingTags,
      )..where((table) => table.cuttingId.equals(cutting.id.value))).go();
      for (final tag in cutting.tags) {
        await _database
            .into(_database.cuttingTags)
            .insert(
              CuttingTagsCompanion.insert(
                cuttingId: cutting.id.value,
                tag: tag,
              ),
            );
      }
      applied += 1;
    }
    return applied;
  }

  Future<int> _insertEvents(
    List<CuttingEvent> events,
    _ExistingIds existing,
    RestoreConflictPolicy policy,
  ) async {
    var applied = 0;
    for (final event in events) {
      final exists = existing.events.contains(event.id.value);
      if (exists && policy == RestoreConflictPolicy.keepExisting) {
        continue;
      }
      await _database
          .into(_database.cuttingEvents)
          .insert(
            CuttingEventsCompanion.insert(
              id: event.id.value,
              cuttingId: event.cuttingId.value,
              occurredAtUtc: event.occurredAtUtc,
              createdAtUtc: event.createdAtUtc,
              kind: event.kind.name,
              note: Value<String>(event.note),
              stage: Value<String?>(event.stage?.name),
              outcome: Value<String?>(event.outcome?.name),
              correctsEventId: Value<String?>(event.correctsEventId?.value),
            ),
            mode: InsertMode.insertOrReplace,
          );
      applied += 1;
    }
    return applied;
  }

  Future<int> _insertReminders(
    List<Reminder> reminders,
    _ExistingIds existing,
    RestoreConflictPolicy policy,
  ) async {
    var applied = 0;
    for (final reminder in reminders) {
      final exists = existing.reminders.contains(reminder.id.value);
      if (exists && policy == RestoreConflictPolicy.keepExisting) {
        continue;
      }
      await _database
          .into(_database.reminders)
          .insert(
            RemindersCompanion.insert(
              id: reminder.id.value,
              cuttingId: reminder.cuttingId.value,
              scheduledForUtc: reminder.scheduledForUtc,
              timeZoneId: Value<String>(reminder.timeZoneId),
              status: reminder.status.name,
              platformNotificationId: Value<String?>(
                reminder.platformNotificationId,
              ),
              createdAtUtc: reminder.createdAtUtc,
              updatedAtUtc: reminder.updatedAtUtc,
              completedAtUtc: Value<DateTime?>(reminder.completedAtUtc),
              snoozedFromUtc: Value<DateTime?>(reminder.snoozedFromUtc),
            ),
            mode: InsertMode.insertOrReplace,
          );
      applied += 1;
    }
    return applied;
  }

  Future<int> _insertMediaAssets(
    List<MediaAsset> mediaAssets,
    _ExistingIds existing,
    RestoreConflictPolicy policy,
  ) async {
    var applied = 0;
    for (final asset in mediaAssets) {
      final exists = existing.mediaAssets.contains(asset.id.value);
      if (exists && policy == RestoreConflictPolicy.keepExisting) {
        continue;
      }
      await _database
          .into(_database.mediaAssets)
          .insert(
            MediaAssetsCompanion.insert(
              id: asset.id.value,
              eventId: asset.eventId.value,
              relativePath: asset.relativePath,
              sha256: asset.sha256,
              mediaType: asset.mediaType,
              caption: Value<String>(asset.caption),
              capturedAtUtc: Value<DateTime?>(asset.capturedAtUtc),
              importedAtUtc: asset.importedAtUtc,
            ),
            mode: InsertMode.insertOrReplace,
          );
      applied += 1;
    }
    return applied;
  }

  Future<void> _clearLibraryRows() async {
    await _database.delete(_database.mediaAssets).go();
    await _database.delete(_database.reminders).go();
    await _database.delete(_database.cuttingEvents).go();
    await _database.delete(_database.cuttingTags).go();
    await _database.delete(_database.cuttings).go();
    await _database.delete(_database.parentPlants).go();
  }

  Future<int> _cancelPendingReminderNotifications() async {
    final reminders = await (_database.select(_database.reminders)).get();
    var cancelled = 0;
    for (final reminder in reminders) {
      if (reminder.status != ReminderStatus.pending.name) {
        continue;
      }
      final platformId = reminder.platformNotificationId;
      if (platformId == null || platformId.trim().isEmpty) {
        continue;
      }
      await _notifications.cancel(platformId);
      cancelled += 1;
    }
    return cancelled;
  }

  Future<int> _clearAllManagedMediaFiles() async {
    final inventory = await _mediaStore.scanInventory();
    var deleted = 0;
    for (final file in inventory.files) {
      if (await _mediaStore.exists(file.relativePath)) {
        await _mediaStore.deleteManagedPath(file.relativePath);
        deleted += 1;
      }
    }
    return deleted;
  }

  Future<int> _clearCacheDirectoryEntries() async {
    if (!await cacheDirectory.exists()) {
      return 0;
    }
    var deleted = 0;
    await for (final entity in cacheDirectory.list()) {
      await entity.delete(recursive: true);
      deleted += 1;
    }
    return deleted;
  }

  String _journalJson(_LibrarySnapshot snapshot) {
    final map = <String, Object?>{
      'format': 'cutting-log-journal',
      'version': 1,
      'exportedAtUtc': _iso(snapshot.exportedAtUtc),
      'parents': snapshot.parents.map(_parentJson).toList(growable: false),
      'cuttings': snapshot.cuttings.map(_cuttingJson).toList(growable: false),
      'events': snapshot.events.map(_eventJson).toList(growable: false),
      'mediaAssets': snapshot.mediaAssets
          .map(_mediaJson)
          .toList(growable: false),
      'reminders': snapshot.reminders
          .map(_reminderJson)
          .toList(growable: false),
    };
    return _canonicalJson(map);
  }

  Map<String, Object?> _parentJson(ParentPlant value) => <String, Object?>{
    'id': value.id.value,
    'nickname': value.nickname,
    'speciesText': value.speciesText,
    'notes': value.notes,
    'createdAtUtc': _iso(value.createdAtUtc),
    'updatedAtUtc': _iso(value.updatedAtUtc),
    'archivedAtUtc': value.archivedAtUtc == null
        ? null
        : _iso(value.archivedAtUtc!),
  };

  Map<String, Object?> _cuttingJson(Cutting value) => <String, Object?>{
    'id': value.id.value,
    'parentId': value.parentId.value,
    'name': value.name,
    'method': value.method,
    'medium': value.medium,
    'location': value.location,
    'tags': value.tags,
    'startedAtUtc': _iso(value.startedAtUtc),
    'createdAtUtc': _iso(value.createdAtUtc),
    'updatedAtUtc': _iso(value.updatedAtUtc),
    'archivedAtUtc': value.archivedAtUtc == null
        ? null
        : _iso(value.archivedAtUtc!),
  };

  Map<String, Object?> _eventJson(CuttingEvent value) => <String, Object?>{
    'id': value.id.value,
    'cuttingId': value.cuttingId.value,
    'occurredAtUtc': _iso(value.occurredAtUtc),
    'createdAtUtc': _iso(value.createdAtUtc),
    'kind': value.kind.name,
    'note': value.note,
    'stage': value.stage?.name,
    'outcome': value.outcome?.name,
    'correctsEventId': value.correctsEventId?.value,
  };

  Map<String, Object?> _mediaJson(MediaAsset value) => <String, Object?>{
    'id': value.id.value,
    'eventId': value.eventId.value,
    'relativePath': value.relativePath,
    'sha256': value.sha256,
    'mediaType': value.mediaType,
    'caption': value.caption,
    'capturedAtUtc': value.capturedAtUtc == null
        ? null
        : _iso(value.capturedAtUtc!),
    'importedAtUtc': _iso(value.importedAtUtc),
  };

  Map<String, Object?> _reminderJson(Reminder value) => <String, Object?>{
    'id': value.id.value,
    'cuttingId': value.cuttingId.value,
    'scheduledForUtc': _iso(value.scheduledForUtc),
    'timeZoneId': value.timeZoneId,
    'status': value.status.name,
    'platformNotificationId': value.platformNotificationId,
    'createdAtUtc': _iso(value.createdAtUtc),
    'updatedAtUtc': _iso(value.updatedAtUtc),
    'completedAtUtc': value.completedAtUtc == null
        ? null
        : _iso(value.completedAtUtc!),
    'snoozedFromUtc': value.snoozedFromUtc == null
        ? null
        : _iso(value.snoozedFromUtc!),
  };

  String _parentsCsv(List<ParentPlant> parents) {
    final rows = <List<String>>[
      <String>[
        'id',
        'nickname',
        'species_text',
        'notes',
        'created_at_utc',
        'updated_at_utc',
        'archived_at_utc',
      ],
      ...parents.map(
        (value) => <String>[
          value.id.value,
          value.nickname,
          value.speciesText ?? '',
          value.notes,
          _iso(value.createdAtUtc),
          _iso(value.updatedAtUtc),
          value.archivedAtUtc == null ? '' : _iso(value.archivedAtUtc!),
        ],
      ),
    ];
    return _csv(rows);
  }

  String _cuttingsCsv(List<Cutting> cuttings) {
    final rows = <List<String>>[
      <String>[
        'id',
        'parent_id',
        'name',
        'method',
        'medium',
        'location',
        'tags',
        'started_at_utc',
        'created_at_utc',
        'updated_at_utc',
        'archived_at_utc',
      ],
      ...cuttings.map(
        (value) => <String>[
          value.id.value,
          value.parentId.value,
          value.name,
          value.method,
          value.medium,
          value.location,
          value.tags.join('|'),
          _iso(value.startedAtUtc),
          _iso(value.createdAtUtc),
          _iso(value.updatedAtUtc),
          value.archivedAtUtc == null ? '' : _iso(value.archivedAtUtc!),
        ],
      ),
    ];
    return _csv(rows);
  }

  String _eventsCsv(List<CuttingEvent> events) {
    final rows = <List<String>>[
      <String>[
        'id',
        'cutting_id',
        'occurred_at_utc',
        'created_at_utc',
        'kind',
        'note',
        'stage',
        'outcome',
        'corrects_event_id',
      ],
      ...events.map(
        (value) => <String>[
          value.id.value,
          value.cuttingId.value,
          _iso(value.occurredAtUtc),
          _iso(value.createdAtUtc),
          value.kind.name,
          value.note,
          value.stage?.name ?? '',
          value.outcome?.name ?? '',
          value.correctsEventId?.value ?? '',
        ],
      ),
    ];
    return _csv(rows);
  }

  String _remindersCsv(List<Reminder> reminders) {
    final rows = <List<String>>[
      <String>[
        'id',
        'cutting_id',
        'scheduled_for_utc',
        'time_zone_id',
        'status',
        'platform_notification_id',
        'created_at_utc',
        'updated_at_utc',
        'completed_at_utc',
        'snoozed_from_utc',
      ],
      ...reminders.map(
        (value) => <String>[
          value.id.value,
          value.cuttingId.value,
          _iso(value.scheduledForUtc),
          value.timeZoneId,
          value.status.name,
          value.platformNotificationId ?? '',
          _iso(value.createdAtUtc),
          _iso(value.updatedAtUtc),
          value.completedAtUtc == null ? '' : _iso(value.completedAtUtc!),
          value.snoozedFromUtc == null ? '' : _iso(value.snoozedFromUtc!),
        ],
      ),
    ];
    return _csv(rows);
  }

  String _csv(List<List<String>> rows) =>
      rows.map((row) => row.map(_escapeCsv).join(',')).join('\n');

  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  String _canonicalJson(Map<String, Object?> value) =>
      const JsonEncoder.withIndent('  ').convert(value);

  String _iso(DateTime value) => value.toUtc().toIso8601String();

  String _timestampStem(DateTime nowUtc) =>
      'cutting-log-${nowUtc.toIso8601String().replaceAll(':', '-')}';

  void _validateArchivePath(String value) {
    if (value.trim().isEmpty) {
      throw const PortabilityException('archive contains an empty path');
    }
    if (value.startsWith('/') || value.contains('\\')) {
      throw PortabilityException('archive path is not allowed: $value');
    }
    final normalized = path.normalize(value);
    final parts = normalized.split('/');
    if (normalized.startsWith('..') ||
        parts.any((part) => part.isEmpty || part == '.' || part == '..')) {
      throw PortabilityException(
        'archive path traversal is not allowed: $value',
      );
    }
  }

  dynamic _decodeJsonUtf8(Uint8List bytes, String fileLabel) {
    try {
      return jsonDecode(utf8.decode(bytes));
    } on Object {
      throw PortabilityException('invalid JSON in $fileLabel');
    }
  }

  static DateTime _defaultClock() => DateTime.now().toUtc();
}

final class _ExistingIds {
  const _ExistingIds({
    required this.parents,
    required this.cuttings,
    required this.events,
    required this.mediaAssets,
    required this.reminders,
  });

  final Set<String> parents;
  final Set<String> cuttings;
  final Set<String> events;
  final Set<String> mediaAssets;
  final Set<String> reminders;
}

final class _MediaArchiveEntry {
  const _MediaArchiveEntry({
    required this.relativePath,
    required this.archivePath,
    required this.sha256,
    required this.bytes,
  });

  final String relativePath;
  final String archivePath;
  final String sha256;
  final Uint8List bytes;
}

final class _BackupMediaFile {
  const _BackupMediaFile({required this.relativePath, required this.bytes});

  final String relativePath;
  final Uint8List bytes;
}

final class _LibrarySnapshot {
  const _LibrarySnapshot({
    required this.exportedAtUtc,
    required this.parents,
    required this.cuttings,
    required this.events,
    required this.mediaAssets,
    required this.reminders,
  });

  final DateTime exportedAtUtc;
  final List<ParentPlant> parents;
  final List<Cutting> cuttings;
  final List<CuttingEvent> events;
  final List<MediaAsset> mediaAssets;
  final List<Reminder> reminders;
}

final class _ParsedBackup {
  const _ParsedBackup({
    required this.createdAtUtc,
    required this.includeMedia,
    required this.snapshot,
    required this.mediaByRelativePath,
  });

  final DateTime createdAtUtc;
  final bool includeMedia;
  final _LibrarySnapshot snapshot;
  final Map<String, _BackupMediaFile> mediaByRelativePath;
}

Map<String, Object?> _asMap(Object? value, [String context = 'JSON']) {
  if (value is Map<String, Object?>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item as Object?));
  }
  throw PortabilityException('$context must be an object');
}

List<Object?> _asList(Object? value, String context) {
  if (value is List<Object?>) {
    return value;
  }
  if (value is List) {
    return value.cast<Object?>();
  }
  throw PortabilityException('$context must be an array');
}

String _requireString(Map<String, Object?> map, String key) {
  final value = map[key];
  if (value is! String) {
    throw PortabilityException('$key must be a string');
  }
  return value;
}

String? _optionalString(Map<String, Object?> map, String key) {
  final value = map[key];
  if (value == null) {
    return null;
  }
  if (value is! String) {
    throw PortabilityException('$key must be a string when present');
  }
  return value;
}

int _requireInt(Map<String, Object?> map, String key) {
  final value = map[key];
  if (value is int) {
    return value;
  }
  throw PortabilityException('$key must be an integer');
}

bool _requireBool(Map<String, Object?> map, String key) {
  final value = map[key];
  if (value is bool) {
    return value;
  }
  throw PortabilityException('$key must be a boolean');
}

DateTime _parseUtc(String value, String key) {
  final parsed = DateTime.tryParse(value);
  if (parsed == null || !parsed.isUtc) {
    throw PortabilityException('$key must be an explicit UTC timestamp');
  }
  return parsed.toUtc();
}

DateTime? _optionalUtc(Map<String, Object?> map, String key) {
  final value = map[key];
  if (value == null) {
    return null;
  }
  if (value is! String) {
    throw PortabilityException('$key must be a UTC timestamp when present');
  }
  return _parseUtc(value, key);
}

int _compareEventsByIdentity(CuttingEvent left, CuttingEvent right) {
  final byCutting = left.cuttingId.compareTo(right.cuttingId);
  if (byCutting != 0) {
    return byCutting;
  }
  final occurred = left.occurredAtUtc.compareTo(right.occurredAtUtc);
  if (occurred != 0) {
    return occurred;
  }
  final created = left.createdAtUtc.compareTo(right.createdAtUtc);
  if (created != 0) {
    return created;
  }
  return left.id.compareTo(right.id);
}

const String _backupSchemaJson = r'''
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://github.com/rwrife/cutting-log/docs/export-schema-v1.json",
  "title": "Cutting Log Journal Backup Schema v1",
  "type": "object",
  "required": [
    "format",
    "version",
    "exportedAtUtc",
    "parents",
    "cuttings",
    "events",
    "mediaAssets",
    "reminders"
  ],
  "properties": {
    "format": { "const": "cutting-log-journal" },
    "version": { "const": 1 },
    "exportedAtUtc": {
      "type": "string",
      "format": "date-time",
      "pattern": "Z$"
    },
    "parents": { "type": "array" },
    "cuttings": { "type": "array" },
    "events": { "type": "array" },
    "mediaAssets": { "type": "array" },
    "reminders": { "type": "array" }
  },
  "additionalProperties": false
}
''';
