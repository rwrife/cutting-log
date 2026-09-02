import 'dart:io';

import 'package:cutting_log/src/data/app_database.dart';
import 'package:cutting_log/src/data/drift_journal_repository.dart';
import 'package:cutting_log/src/domain/journal_data_repository.dart';
import 'package:cutting_log/src/domain/journal_entities.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  final base = DateTime.utc(2026, 1, 1, 12);
  late AppDatabase database;
  late DriftJournalRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory(logStatements: false));
    repository = DriftJournalRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'persists lineage, tags, ordered events, media, and reminder state',
    () async {
      final parent = _parent(base);
      await repository.createParentPlant(parent);
      final cutting = _cutting(
        base,
        parent.id,
        tags: const <String>['Water', 'north'],
      );
      await repository.createCutting(cutting);

      final later = _stageEvent(
        id: 'event-later',
        cuttingId: cutting.id,
        stage: CuttingStage.rooting,
        occurredAtUtc: base.add(const Duration(days: 2)),
      );
      final earlier = _stageEvent(
        id: 'event-earlier',
        cuttingId: cutting.id,
        stage: CuttingStage.callusing,
        occurredAtUtc: base.add(const Duration(days: 1)),
      );
      await repository.appendEvent(earlier);
      await repository.appendEvent(later);

      final asset = MediaAsset(
        id: EntityId('media-1'),
        eventId: later.id,
        relativePath: 'media/cutting-1/rooting.jpg',
        sha256: 'a' * 64,
        mediaType: 'image/jpeg',
        caption: 'User observation',
        importedAtUtc: base.add(const Duration(days: 2)),
      );
      await repository.addMediaAsset(asset);

      final reminder = Reminder(
        id: EntityId('reminder-1'),
        cuttingId: cutting.id,
        scheduledForUtc: base.add(const Duration(days: 7)),
        timeZoneId: 'America/Los_Angeles',
        status: ReminderStatus.pending,
        createdAtUtc: base,
        updatedAtUtc: base,
      );
      await repository.createReminder(reminder);
      await repository.updateReminder(
        Reminder(
          id: reminder.id,
          cuttingId: cutting.id,
          scheduledForUtc: reminder.scheduledForUtc,
          timeZoneId: reminder.timeZoneId,
          status: ReminderStatus.completed,
          createdAtUtc: base,
          updatedAtUtc: base.add(const Duration(days: 7)),
          completedAtUtc: base.add(const Duration(days: 7)),
        ),
      );

      final storedCutting = await repository.getCutting(cutting.id);
      final events = await repository.getCuttingEvents(cutting.id);
      final assets = await repository.getMediaAssets(later.id);
      final reminders = await repository.getReminders(cutting.id);

      expect(storedCutting?.parentId, parent.id);
      expect(storedCutting?.tags, <String>['north', 'water']);
      expect(events.map((event) => event.id.value), <String>[
        'event-earlier',
        'event-later',
      ]);
      expect(deriveCuttingState(events).stage, CuttingStage.rooting);
      expect(assets.single.relativePath, asset.relativePath);
      expect(reminders.single.status, ReminderStatus.completed);
      expect(reminders.single.timeZoneId, 'America/Los_Angeles');
    },
  );

  test('updates and archives records without deleting lineage', () async {
    final parent = _parent(base);
    await repository.createParentPlant(parent);
    final cutting = _cutting(base, parent.id);
    await repository.createCutting(cutting);
    final changedAt = base.add(const Duration(days: 1));

    await repository.updateParentPlant(
      ParentPlant(
        id: parent.id,
        nickname: 'Updated parent',
        speciesText: 'User-entered species',
        createdAtUtc: base,
        updatedAtUtc: changedAt,
      ),
    );
    await repository.archiveCutting(cutting.id, changedAt);
    await repository.archiveParentPlant(parent.id, changedAt);

    expect(
      (await repository.getParentPlant(parent.id))?.nickname,
      'Updated parent',
    );
    expect(
      (await repository.getParentPlant(parent.id))?.archivedAtUtc,
      changedAt,
    );
    expect((await repository.getCutting(cutting.id))?.archivedAtUtc, changedAt);
    expect((await repository.getCutting(cutting.id))?.parentId, parent.id);
    await expectLater(
      repository.updateCutting(
        Cutting(
          id: cutting.id,
          parentId: EntityId('different-parent'),
          name: cutting.name,
          method: cutting.method,
          startedAtUtc: cutting.startedAtUtc,
          createdAtUtc: cutting.createdAtUtc,
          updatedAtUtc: changedAt,
          archivedAtUtc: changedAt,
        ),
      ),
      throwsA(isA<JournalTransitionException>()),
    );
  });

  test(
    'rejects duplicate IDs and invalid event/reminder transitions',
    () async {
      final parent = _parent(base);
      await repository.createParentPlant(parent);
      await expectLater(
        repository.createParentPlant(parent),
        throwsA(isA<JournalConflictException>()),
      );
      final cutting = _cutting(base, parent.id);
      await repository.createCutting(cutting);
      await repository.appendEvent(
        _stageEvent(
          id: 'rooting',
          cuttingId: cutting.id,
          stage: CuttingStage.rooting,
          occurredAtUtc: base,
        ),
      );
      await expectLater(
        repository.appendEvent(
          _stageEvent(
            id: 'backward',
            cuttingId: cutting.id,
            stage: CuttingStage.callusing,
            occurredAtUtc: base.add(const Duration(days: 1)),
          ),
        ),
        throwsA(isA<JournalTransitionException>()),
      );

      final completed = Reminder(
        id: EntityId('completed-reminder'),
        cuttingId: cutting.id,
        scheduledForUtc: base,
        timeZoneId: 'UTC',
        status: ReminderStatus.completed,
        createdAtUtc: base,
        updatedAtUtc: base,
        completedAtUtc: base,
      );
      await repository.createReminder(completed);
      await expectLater(
        repository.updateReminder(
          Reminder(
            id: completed.id,
            cuttingId: cutting.id,
            scheduledForUtc: base,
            timeZoneId: 'UTC',
            status: ReminderStatus.pending,
            createdAtUtc: base,
            updatedAtUtc: base.add(const Duration(hours: 1)),
          ),
        ),
        throwsA(isA<JournalTransitionException>()),
      );
    },
  );

  test(
    'rolls back aggregate creation when its initial event conflicts',
    () async {
      final parent = _parent(base);
      await repository.createParentPlant(parent);
      final first = _cutting(base, parent.id);
      final existingEvent = _stageEvent(
        id: 'duplicate-event',
        cuttingId: first.id,
        stage: CuttingStage.callusing,
        occurredAtUtc: base,
      );
      await repository.createCuttingWithInitialEvent(first, existingEvent);

      final second = _cutting(base, parent.id, id: 'cutting-2');
      final conflictingEvent = _stageEvent(
        id: existingEvent.id.value,
        cuttingId: second.id,
        stage: CuttingStage.callusing,
        occurredAtUtc: base,
      );
      await expectLater(
        repository.createCuttingWithInitialEvent(second, conflictingEvent),
        throwsA(isA<JournalConflictException>()),
      );

      expect(await repository.getCutting(second.id), isNull);
    },
  );

  test('survives database close and restart', () async {
    await database.close();
    final temporary = await Directory.systemTemp.createTemp(
      'cutting-log-restart-',
    );
    final path = '${temporary.path}/journal.sqlite3';
    try {
      final firstDatabase = AppDatabase(
        NativeDatabase(File(path), logStatements: false),
      );
      final firstRepository = DriftJournalRepository(firstDatabase);
      final parent = _parent(base);
      await firstRepository.createParentPlant(parent);
      await firstDatabase.close();

      final reopenedDatabase = AppDatabase(
        NativeDatabase(File(path), logStatements: false),
      );
      final reopenedRepository = DriftJournalRepository(reopenedDatabase);
      expect(
        (await reopenedRepository.getParentPlant(parent.id))?.nickname,
        parent.nickname,
      );
      await reopenedDatabase.close();
    } finally {
      await temporary.delete(recursive: true);
    }
  });

  test(
    'migrates the checked-in version 1 fixture to schema version 2',
    () async {
      await database.close();
      final temporary = await Directory.systemTemp.createTemp(
        'cutting-log-migration-',
      );
      final path = '${temporary.path}/fixture.sqlite3';
      try {
        final fixtureSql = await File('test/fixtures/schema_v1.sql')
            .readAsString();
        final fixtureDatabase = sqlite3.open(path);
        fixtureDatabase.execute(fixtureSql);
        fixtureDatabase.close();

        final migratedDatabase = AppDatabase(
          NativeDatabase(File(path), logStatements: false),
        );
        final migratedRepository = DriftJournalRepository(migratedDatabase);
        final reminders = await migratedRepository.getReminders(
          EntityId('fixture-cutting'),
        );
        final version = await migratedDatabase
            .customSelect('PRAGMA user_version')
            .getSingle();

        expect(version.read<int>('user_version'), 2);
        expect(reminders.single.timeZoneId, 'UTC');
        await migratedDatabase.close();
      } finally {
        await temporary.delete(recursive: true);
      }
    },
  );
}

Cutting _cutting(
  DateTime base,
  EntityId parentId, {
  String id = 'cutting-1',
  Iterable<String> tags = const <String>[],
}) => Cutting(
  id: EntityId(id),
  parentId: parentId,
  name: 'Cutting',
  method: 'stem',
  tags: tags,
  startedAtUtc: base,
  createdAtUtc: base,
  updatedAtUtc: base,
);

ParentPlant _parent(DateTime base) => ParentPlant(
  id: EntityId('parent-1'),
  nickname: 'Parent',
  createdAtUtc: base,
  updatedAtUtc: base,
);

CuttingEvent _stageEvent({
  required String id,
  required EntityId cuttingId,
  required CuttingStage stage,
  required DateTime occurredAtUtc,
}) => CuttingEvent(
  id: EntityId(id),
  cuttingId: cuttingId,
  occurredAtUtc: occurredAtUtc,
  createdAtUtc: occurredAtUtc,
  kind: CuttingEventKind.stage,
  stage: stage,
);
