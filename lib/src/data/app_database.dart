import 'package:drift/drift.dart';

part 'app_database.g.dart';

@DataClassName('ParentPlantRow')
class ParentPlants extends Table {
  TextColumn get id => text()();

  TextColumn get nickname => text()();

  TextColumn get speciesText => text().nullable()();

  TextColumn get notes => text().withDefault(const Constant(''))();

  DateTimeColumn get createdAtUtc => dateTime()();

  DateTimeColumn get updatedAtUtc => dateTime()();

  DateTimeColumn get archivedAtUtc => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('CuttingRow')
class Cuttings extends Table {
  TextColumn get id => text()();

  TextColumn get parentId => text().customConstraint(
    'NOT NULL REFERENCES parent_plants(id) ON DELETE RESTRICT',
  )();

  TextColumn get name => text()();

  TextColumn get method => text()();

  TextColumn get medium => text().withDefault(const Constant(''))();

  TextColumn get location => text().withDefault(const Constant(''))();

  DateTimeColumn get startedAtUtc => dateTime()();

  DateTimeColumn get createdAtUtc => dateTime()();

  DateTimeColumn get updatedAtUtc => dateTime()();

  DateTimeColumn get archivedAtUtc => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('CuttingTagRow')
class CuttingTags extends Table {
  TextColumn get cuttingId => text().customConstraint(
    'NOT NULL REFERENCES cuttings(id) ON DELETE CASCADE',
  )();

  TextColumn get tag => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{cuttingId, tag};
}

@DataClassName('CuttingEventRow')
class CuttingEvents extends Table {
  TextColumn get id => text()();

  TextColumn get cuttingId => text().customConstraint(
    'NOT NULL REFERENCES cuttings(id) ON DELETE CASCADE',
  )();

  DateTimeColumn get occurredAtUtc => dateTime()();

  DateTimeColumn get createdAtUtc => dateTime()();

  TextColumn get kind => text()();

  TextColumn get note => text().withDefault(const Constant(''))();

  TextColumn get stage => text().nullable()();

  TextColumn get outcome => text().nullable()();

  TextColumn get correctsEventId => text().nullable().customConstraint(
    'NULL REFERENCES cutting_events(id) ON DELETE RESTRICT',
  )();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('MediaAssetRow')
class MediaAssets extends Table {
  TextColumn get id => text()();

  TextColumn get eventId => text().customConstraint(
    'NOT NULL REFERENCES cutting_events(id) ON DELETE CASCADE',
  )();

  TextColumn get relativePath => text()();

  TextColumn get sha256 => text()();

  TextColumn get mediaType => text()();

  TextColumn get caption => text().withDefault(const Constant(''))();

  DateTimeColumn get capturedAtUtc => dateTime().nullable()();

  DateTimeColumn get importedAtUtc => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('ReminderRow')
class Reminders extends Table {
  TextColumn get id => text()();

  TextColumn get cuttingId => text().customConstraint(
    'NOT NULL REFERENCES cuttings(id) ON DELETE CASCADE',
  )();

  DateTimeColumn get scheduledForUtc => dateTime()();

  TextColumn get timeZoneId => text().withDefault(const Constant('UTC'))();

  TextColumn get status => text()();

  TextColumn get platformNotificationId => text().nullable()();

  DateTimeColumn get createdAtUtc => dateTime()();

  DateTimeColumn get updatedAtUtc => dateTime()();

  DateTimeColumn get completedAtUtc => dateTime().nullable()();

  DateTimeColumn get snoozedFromUtc => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DriftDatabase(
  tables: <Type>[
    ParentPlants,
    Cuttings,
    CuttingTags,
    CuttingEvents,
    MediaAssets,
    Reminders,
  ],
)
final class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await _createIndexes();
    },
    onCreate: (migrator) async {
      await migrator.createAll();
      await _createIndexes();
    },
    onUpgrade: (migrator, from, to) async {
      if (from == 1) {
        await migrator.addColumn(reminders, reminders.timeZoneId);
      }
      await _createIndexes();
    },
  );

  Future<void> _createIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS cuttings_parent_id_idx ON cuttings(parent_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS cutting_events_order_idx '
      'ON cutting_events(cutting_id, occurred_at_utc, created_at_utc, id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS media_assets_event_id_idx ON media_assets(event_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS reminders_due_idx '
      'ON reminders(status, scheduled_for_utc)',
    );
  }
}
