import 'package:cutting_log/src/data/app_database.dart';
import 'package:cutting_log/src/domain/journal_data_repository.dart';
import 'package:cutting_log/src/domain/journal_entities.dart';
import 'package:drift/drift.dart';

final class DriftJournalRepository implements JournalDataRepository {
  const DriftJournalRepository(this._database);

  final AppDatabase _database;

  @override
  Future<void> addMediaAsset(MediaAsset asset) =>
      _database.transaction(() async {
        await _ensureAbsent(
          _database.mediaAssets,
          _database.mediaAssets.id,
          asset.id,
        );
        await _ensurePresent(
          _database.cuttingEvents,
          _database.cuttingEvents.id,
          asset.eventId,
          'event',
        );
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
            );
      });

  @override
  Future<void> appendEvent(CuttingEvent event) =>
      _database.transaction(() => _appendEvent(event));

  @override
  Future<void> archiveCutting(EntityId id, DateTime archivedAtUtc) async {
    final existing = await getCutting(id);
    if (existing == null) {
      throw const JournalNotFoundException('cutting does not exist');
    }
    await updateCutting(
      Cutting(
        id: existing.id,
        parentId: existing.parentId,
        name: existing.name,
        method: existing.method,
        medium: existing.medium,
        location: existing.location,
        tags: existing.tags,
        startedAtUtc: existing.startedAtUtc,
        createdAtUtc: existing.createdAtUtc,
        updatedAtUtc: archivedAtUtc,
        archivedAtUtc: archivedAtUtc,
      ),
    );
  }

  @override
  Future<void> archiveParentPlant(EntityId id, DateTime archivedAtUtc) async {
    final existing = await getParentPlant(id);
    if (existing == null) {
      throw const JournalNotFoundException('parent plant does not exist');
    }
    await updateParentPlant(
      ParentPlant(
        id: existing.id,
        nickname: existing.nickname,
        speciesText: existing.speciesText,
        notes: existing.notes,
        createdAtUtc: existing.createdAtUtc,
        updatedAtUtc: archivedAtUtc,
        archivedAtUtc: archivedAtUtc,
      ),
    );
  }

  @override
  Future<void> createCutting(Cutting cutting) =>
      _database.transaction(() => _insertCutting(cutting));

  @override
  Future<void> createCuttingWithInitialEvent(
    Cutting cutting,
    CuttingEvent initialEvent,
  ) => _database.transaction(() async {
    if (initialEvent.cuttingId != cutting.id) {
      throw const JournalTransitionException(
        'initial event must belong to the new cutting',
      );
    }
    await _insertCutting(cutting);
    await _appendEvent(initialEvent);
  });

  @override
  Future<void> createParentPlant(ParentPlant parent) =>
      _database.transaction(() async {
        await _ensureAbsent(
          _database.parentPlants,
          _database.parentPlants.id,
          parent.id,
        );
        await _database
            .into(_database.parentPlants)
            .insert(_parentCompanion(parent));
      });

  @override
  Future<void> createReminder(Reminder reminder) =>
      _database.transaction(() async {
        await _ensureAbsent(
          _database.reminders,
          _database.reminders.id,
          reminder.id,
        );
        await _ensurePresent(
          _database.cuttings,
          _database.cuttings.id,
          reminder.cuttingId,
          'cutting',
        );
        await _database
            .into(_database.reminders)
            .insert(_reminderCompanion(reminder));
      });

  @override
  Future<Cutting?> getCutting(EntityId id) async {
    final row = await (_database.select(
      _database.cuttings,
    )..where((table) => table.id.equals(id.value))).getSingleOrNull();
    if (row == null) {
      return null;
    }
    final tags =
        await (_database.select(_database.cuttingTags)
              ..where((table) => table.cuttingId.equals(id.value))
              ..orderBy(<OrderingTerm Function(CuttingTags)>[
                (table) => OrderingTerm.asc(table.tag),
              ]))
            .get();
    return _cutting(row, tags.map((tag) => tag.tag));
  }

  @override
  Future<List<Cutting>> getCuttings({EntityId? parentId}) async {
    final query = _database.select(_database.cuttings);
    if (parentId != null) {
      query.where((table) => table.parentId.equals(parentId.value));
    }
    query.orderBy(<OrderingTerm Function(Cuttings)>[
      (table) => OrderingTerm.desc(table.startedAtUtc),
      (table) => OrderingTerm.asc(table.id),
    ]);
    final rows = await query.get();
    final values = <Cutting>[];
    for (final row in rows) {
      final tags =
          await (_database.select(_database.cuttingTags)
                ..where((table) => table.cuttingId.equals(row.id))
                ..orderBy(<OrderingTerm Function(CuttingTags)>[
                  (table) => OrderingTerm.asc(table.tag),
                ]))
              .get();
      values.add(_cutting(row, tags.map((tag) => tag.tag)));
    }
    return values;
  }

  @override
  Future<List<CuttingEvent>> getCuttingEvents(EntityId cuttingId) async {
    final rows =
        await (_database.select(_database.cuttingEvents)
              ..where((table) => table.cuttingId.equals(cuttingId.value))
              ..orderBy(<OrderingTerm Function(CuttingEvents)>[
                (table) => OrderingTerm.asc(table.occurredAtUtc),
                (table) => OrderingTerm.asc(table.createdAtUtc),
                (table) => OrderingTerm.asc(table.id),
              ]))
            .get();
    return rows.map(_event).toList(growable: false);
  }

  @override
  Future<MediaAsset?> getMediaAsset(EntityId id) async {
    final row = await (_database.select(
      _database.mediaAssets,
    )..where((table) => table.id.equals(id.value))).getSingleOrNull();
    return row == null ? null : _mediaAsset(row);
  }

  @override
  Future<List<MediaAsset>> getMediaAssets(EntityId eventId) async {
    final rows =
        await (_database.select(_database.mediaAssets)
              ..where((table) => table.eventId.equals(eventId.value))
              ..orderBy(<OrderingTerm Function(MediaAssets)>[
                (table) => OrderingTerm.asc(table.importedAtUtc),
                (table) => OrderingTerm.asc(table.id),
              ]))
            .get();
    return rows.map(_mediaAsset).toList(growable: false);
  }

  @override
  Future<List<MediaAsset>> getAllMediaAssets() async {
    final rows =
        await (_database.select(_database.mediaAssets)
              ..orderBy(<OrderingTerm Function(MediaAssets)>[
                (table) => OrderingTerm.asc(table.importedAtUtc),
                (table) => OrderingTerm.asc(table.id),
              ]))
            .get();
    return rows.map(_mediaAsset).toList(growable: false);
  }

  @override
  Future<ParentPlant?> getParentPlant(EntityId id) async {
    final row = await (_database.select(
      _database.parentPlants,
    )..where((table) => table.id.equals(id.value))).getSingleOrNull();
    return row == null ? null : _parent(row);
  }

  @override
  Future<List<ParentPlant>> getParentPlants() async {
    final rows =
        await (_database.select(_database.parentPlants)
              ..orderBy(<OrderingTerm Function(ParentPlants)>[
                (table) => OrderingTerm.asc(table.nickname),
                (table) => OrderingTerm.asc(table.id),
              ]))
            .get();
    return rows.map(_parent).toList(growable: false);
  }

  @override
  Future<List<Reminder>> getReminders(EntityId cuttingId) async {
    final rows =
        await (_database.select(_database.reminders)
              ..where((table) => table.cuttingId.equals(cuttingId.value))
              ..orderBy(<OrderingTerm Function(Reminders)>[
                (table) => OrderingTerm.asc(table.scheduledForUtc),
                (table) => OrderingTerm.asc(table.id),
              ]))
            .get();
    return rows.map(_reminder).toList(growable: false);
  }

  @override
  Future<void> updateCutting(Cutting cutting) => _database.transaction(
    () async {
      final existing = await (_database.select(
        _database.cuttings,
      )..where((table) => table.id.equals(cutting.id.value))).getSingleOrNull();
      if (existing == null) {
        throw const JournalNotFoundException('cutting does not exist');
      }
      if (existing.parentId != cutting.parentId.value ||
          existing.startedAtUtc.toUtc() != cutting.startedAtUtc ||
          existing.createdAtUtc.toUtc() != cutting.createdAtUtc) {
        throw const JournalTransitionException(
          'cutting lineage and creation timestamps are immutable',
        );
      }
      _ensureMonotonicUpdate(
        existing.updatedAtUtc,
        cutting.updatedAtUtc,
        existing.archivedAtUtc,
        cutting.archivedAtUtc,
      );
      await _ensurePresent(
        _database.parentPlants,
        _database.parentPlants.id,
        cutting.parentId,
        'parent plant',
      );
      await (_database.update(_database.cuttings)
            ..where((table) => table.id.equals(cutting.id.value)))
          .write(_cuttingCompanion(cutting));
      await (_database.delete(
        _database.cuttingTags,
      )..where((table) => table.cuttingId.equals(cutting.id.value))).go();
      await _insertTags(cutting);
    },
  );

  @override
  Future<void> updateParentPlant(ParentPlant parent) => _database.transaction(
    () async {
      final existing = await (_database.select(
        _database.parentPlants,
      )..where((table) => table.id.equals(parent.id.value))).getSingleOrNull();
      if (existing == null) {
        throw const JournalNotFoundException('parent plant does not exist');
      }
      if (existing.createdAtUtc.toUtc() != parent.createdAtUtc) {
        throw const JournalTransitionException(
          'parent creation timestamp is immutable',
        );
      }
      _ensureMonotonicUpdate(
        existing.updatedAtUtc,
        parent.updatedAtUtc,
        existing.archivedAtUtc,
        parent.archivedAtUtc,
      );
      await (_database.update(_database.parentPlants)
            ..where((table) => table.id.equals(parent.id.value)))
          .write(_parentCompanion(parent));
    },
  );

  @override
  Future<void> updateReminder(
    Reminder reminder,
  ) => _database.transaction(() async {
    final existing = await (_database.select(
      _database.reminders,
    )..where((table) => table.id.equals(reminder.id.value))).getSingleOrNull();
    if (existing == null) {
      throw const JournalNotFoundException('reminder does not exist');
    }
    final previous = ReminderStatus.values.byName(existing.status);
    if (!Reminder.canTransition(previous, reminder.status)) {
      throw const JournalTransitionException(
        'invalid reminder status transition',
      );
    }
    if (existing.cuttingId != reminder.cuttingId.value) {
      throw const JournalTransitionException('reminders cannot change cutting');
    }
    if (existing.createdAtUtc.toUtc() != reminder.createdAtUtc ||
        reminder.updatedAtUtc.isBefore(existing.updatedAtUtc.toUtc())) {
      throw const JournalTransitionException(
        'reminder creation is immutable and updates must be monotonic',
      );
    }
    if (previous != ReminderStatus.pending &&
        (existing.scheduledForUtc.toUtc() != reminder.scheduledForUtc ||
            existing.timeZoneId != reminder.timeZoneId ||
            existing.platformNotificationId !=
                reminder.platformNotificationId ||
            existing.completedAtUtc?.toUtc() != reminder.completedAtUtc ||
            existing.snoozedFromUtc?.toUtc() != reminder.snoozedFromUtc)) {
      throw const JournalTransitionException(
        'terminal reminder details are immutable',
      );
    }
    await (_database.update(_database.reminders)
          ..where((table) => table.id.equals(reminder.id.value)))
        .write(_reminderCompanion(reminder));
  });

  @override
  Future<void> removeMediaAsset(EntityId id) async {
    await (_database.delete(
      _database.mediaAssets,
    )..where((table) => table.id.equals(id.value))).go();
  }

  @override
  Future<void> removeAllMediaAssets() async {
    await _database.delete(_database.mediaAssets).go();
  }

  Future<void> _appendEvent(CuttingEvent event) async {
    await _ensureAbsent(
      _database.cuttingEvents,
      _database.cuttingEvents.id,
      event.id,
    );
    await _ensurePresent(
      _database.cuttings,
      _database.cuttings.id,
      event.cuttingId,
      'cutting',
    );
    final events = await getCuttingEvents(event.cuttingId);
    try {
      deriveCuttingState(<CuttingEvent>[...events, event]);
    } on StateError catch (error) {
      throw JournalTransitionException(error.message.toString());
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
        );
  }

  Future<void> _ensureAbsent<T extends Table, D>(
    TableInfo<T, D> table,
    GeneratedColumn<String> column,
    EntityId id,
  ) async {
    final row = await (_database.select(
      table,
    )..where((_) => column.equals(id.value))).getSingleOrNull();
    if (row != null) {
      throw JournalConflictException('duplicate ID: ${id.value}');
    }
  }

  Future<void> _ensurePresent<T extends Table, D>(
    TableInfo<T, D> table,
    GeneratedColumn<String> column,
    EntityId id,
    String entityName,
  ) async {
    final row = await (_database.select(
      table,
    )..where((_) => column.equals(id.value))).getSingleOrNull();
    if (row == null) {
      throw JournalNotFoundException('$entityName does not exist');
    }
  }

  Future<void> _insertCutting(Cutting cutting) async {
    await _ensureAbsent(_database.cuttings, _database.cuttings.id, cutting.id);
    await _ensurePresent(
      _database.parentPlants,
      _database.parentPlants.id,
      cutting.parentId,
      'parent plant',
    );
    await _database.into(_database.cuttings).insert(_cuttingCompanion(cutting));
    await _insertTags(cutting);
  }

  Future<void> _insertTags(Cutting cutting) async {
    for (final tag in cutting.tags) {
      await _database
          .into(_database.cuttingTags)
          .insert(
            CuttingTagsCompanion.insert(cuttingId: cutting.id.value, tag: tag),
          );
    }
  }
}

void _ensureMonotonicUpdate(
  DateTime existingUpdatedAt,
  DateTime nextUpdatedAt,
  DateTime? existingArchivedAt,
  DateTime? nextArchivedAt,
) {
  if (nextUpdatedAt.isBefore(existingUpdatedAt.toUtc())) {
    throw const JournalTransitionException(
      'updates must not move backward in time',
    );
  }
  final archived = existingArchivedAt?.toUtc();
  if (archived != null && nextArchivedAt != archived) {
    throw const JournalTransitionException(
      'archival state cannot be silently rewritten',
    );
  }
}

Cutting _cutting(CuttingRow row, Iterable<String> tags) => Cutting(
  id: EntityId(row.id),
  parentId: EntityId(row.parentId),
  name: row.name,
  method: row.method,
  medium: row.medium,
  location: row.location,
  tags: tags,
  startedAtUtc: row.startedAtUtc.toUtc(),
  createdAtUtc: row.createdAtUtc.toUtc(),
  updatedAtUtc: row.updatedAtUtc.toUtc(),
  archivedAtUtc: row.archivedAtUtc?.toUtc(),
);

CuttingsCompanion _cuttingCompanion(Cutting cutting) => CuttingsCompanion(
  id: Value<String>(cutting.id.value),
  parentId: Value<String>(cutting.parentId.value),
  name: Value<String>(cutting.name),
  method: Value<String>(cutting.method),
  medium: Value<String>(cutting.medium),
  location: Value<String>(cutting.location),
  startedAtUtc: Value<DateTime>(cutting.startedAtUtc),
  createdAtUtc: Value<DateTime>(cutting.createdAtUtc),
  updatedAtUtc: Value<DateTime>(cutting.updatedAtUtc),
  archivedAtUtc: Value<DateTime?>(cutting.archivedAtUtc),
);

CuttingEvent _event(CuttingEventRow row) => CuttingEvent(
  id: EntityId(row.id),
  cuttingId: EntityId(row.cuttingId),
  occurredAtUtc: row.occurredAtUtc.toUtc(),
  createdAtUtc: row.createdAtUtc.toUtc(),
  kind: CuttingEventKind.values.byName(row.kind),
  note: row.note,
  stage: row.stage == null ? null : CuttingStage.values.byName(row.stage!),
  outcome: row.outcome == null
      ? null
      : CuttingOutcome.values.byName(row.outcome!),
  correctsEventId: row.correctsEventId == null
      ? null
      : EntityId(row.correctsEventId!),
);

MediaAsset _mediaAsset(MediaAssetRow row) => MediaAsset(
  id: EntityId(row.id),
  eventId: EntityId(row.eventId),
  relativePath: row.relativePath,
  sha256: row.sha256,
  mediaType: row.mediaType,
  caption: row.caption,
  capturedAtUtc: row.capturedAtUtc?.toUtc(),
  importedAtUtc: row.importedAtUtc.toUtc(),
);

ParentPlant _parent(ParentPlantRow row) => ParentPlant(
  id: EntityId(row.id),
  nickname: row.nickname,
  speciesText: row.speciesText,
  notes: row.notes,
  createdAtUtc: row.createdAtUtc.toUtc(),
  updatedAtUtc: row.updatedAtUtc.toUtc(),
  archivedAtUtc: row.archivedAtUtc?.toUtc(),
);

ParentPlantsCompanion _parentCompanion(ParentPlant parent) =>
    ParentPlantsCompanion(
      id: Value<String>(parent.id.value),
      nickname: Value<String>(parent.nickname),
      speciesText: Value<String?>(parent.speciesText),
      notes: Value<String>(parent.notes),
      createdAtUtc: Value<DateTime>(parent.createdAtUtc),
      updatedAtUtc: Value<DateTime>(parent.updatedAtUtc),
      archivedAtUtc: Value<DateTime?>(parent.archivedAtUtc),
    );

Reminder _reminder(ReminderRow row) => Reminder(
  id: EntityId(row.id),
  cuttingId: EntityId(row.cuttingId),
  scheduledForUtc: row.scheduledForUtc.toUtc(),
  timeZoneId: row.timeZoneId,
  status: ReminderStatus.values.byName(row.status),
  platformNotificationId: row.platformNotificationId,
  createdAtUtc: row.createdAtUtc.toUtc(),
  updatedAtUtc: row.updatedAtUtc.toUtc(),
  completedAtUtc: row.completedAtUtc?.toUtc(),
  snoozedFromUtc: row.snoozedFromUtc?.toUtc(),
);

RemindersCompanion _reminderCompanion(Reminder reminder) => RemindersCompanion(
  id: Value<String>(reminder.id.value),
  cuttingId: Value<String>(reminder.cuttingId.value),
  scheduledForUtc: Value<DateTime>(reminder.scheduledForUtc),
  timeZoneId: Value<String>(reminder.timeZoneId),
  status: Value<String>(reminder.status.name),
  platformNotificationId: Value<String?>(reminder.platformNotificationId),
  createdAtUtc: Value<DateTime>(reminder.createdAtUtc),
  updatedAtUtc: Value<DateTime>(reminder.updatedAtUtc),
  completedAtUtc: Value<DateTime?>(reminder.completedAtUtc),
  snoozedFromUtc: Value<DateTime?>(reminder.snoozedFromUtc),
);
