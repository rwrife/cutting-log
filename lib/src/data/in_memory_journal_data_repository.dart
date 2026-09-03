import 'package:cutting_log/src/domain/journal_data_repository.dart';
import 'package:cutting_log/src/domain/journal_entities.dart';

/// Small local adapter for the shell and widget tests. Production composition
/// can substitute the versioned Drift adapter without changing workflows.
final class InMemoryJournalDataRepository implements JournalDataRepository {
  final _parents = <EntityId, ParentPlant>{};
  final _cuttings = <EntityId, Cutting>{};
  final _events = <EntityId, CuttingEvent>{};

  @override
  Future<void> createParentPlant(ParentPlant value) async {
    if (_parents.containsKey(value.id)) {
      throw const JournalConflictException('duplicate parent ID');
    }
    _parents[value.id] = value;
  }

  @override
  Future<void> createCutting(Cutting value) async {
    if (!_parents.containsKey(value.parentId)) {
      throw const JournalNotFoundException('parent plant does not exist');
    }
    if (_cuttings.containsKey(value.id)) {
      throw const JournalConflictException('duplicate cutting ID');
    }
    _cuttings[value.id] = value;
  }

  @override
  Future<void> createCuttingWithInitialEvent(
    Cutting cutting,
    CuttingEvent event,
  ) async {
    await createCutting(cutting);
    try {
      await appendEvent(event);
    } catch (_) {
      _cuttings.remove(cutting.id);
      rethrow;
    }
  }

  @override
  Future<void> appendEvent(CuttingEvent value) async {
    if (!_cuttings.containsKey(value.cuttingId)) {
      throw const JournalNotFoundException('cutting does not exist');
    }
    if (_events.containsKey(value.id)) {
      throw const JournalConflictException('duplicate event ID');
    }
    deriveCuttingState(<CuttingEvent>[
      ...await getCuttingEvents(value.cuttingId),
      value,
    ]);
    _events[value.id] = value;
  }

  @override
  Future<ParentPlant?> getParentPlant(EntityId id) async => _parents[id];
  @override
  Future<Cutting?> getCutting(EntityId id) async => _cuttings[id];
  @override
  Future<List<CuttingEvent>> getCuttingEvents(EntityId id) async =>
      _events.values.where((e) => e.cuttingId == id).toList()
        ..sort((a, b) => a.occurredAtUtc.compareTo(b.occurredAtUtc));
  @override
  Future<void> updateParentPlant(ParentPlant p) async {
    if (!_parents.containsKey(p.id)) {
      throw const JournalNotFoundException('parent plant does not exist');
    }
    _parents[p.id] = p;
  }

  @override
  Future<void> updateCutting(Cutting c) async {
    if (!_cuttings.containsKey(c.id)) {
      throw const JournalNotFoundException('cutting does not exist');
    }
    _cuttings[c.id] = c;
  }

  @override
  Future<void> archiveParentPlant(EntityId id, DateTime at) async {
    final p = await getParentPlant(id);
    if (p == null) {
      throw const JournalNotFoundException('parent plant does not exist');
    }
    await updateParentPlant(
      ParentPlant(
        id: p.id,
        nickname: p.nickname,
        speciesText: p.speciesText,
        notes: p.notes,
        createdAtUtc: p.createdAtUtc,
        updatedAtUtc: at,
        archivedAtUtc: at,
      ),
    );
  }

  @override
  Future<void> archiveCutting(EntityId id, DateTime at) async {
    final c = await getCutting(id);
    if (c == null) {
      throw const JournalNotFoundException('cutting does not exist');
    }
    await updateCutting(
      Cutting(
        id: c.id,
        parentId: c.parentId,
        name: c.name,
        method: c.method,
        medium: c.medium,
        location: c.location,
        tags: c.tags,
        startedAtUtc: c.startedAtUtc,
        createdAtUtc: c.createdAtUtc,
        updatedAtUtc: at,
        archivedAtUtc: at,
      ),
    );
  }

  @override
  Future<void> addMediaAsset(MediaAsset asset) async =>
      throw UnsupportedError('Media is not part of the capture workflow');
  @override
  Future<List<MediaAsset>> getMediaAssets(EntityId id) async => const [];
  @override
  Future<void> createReminder(Reminder reminder) async =>
      throw UnsupportedError('Reminders are not part of the capture workflow');
  @override
  Future<List<Reminder>> getReminders(EntityId id) async => const [];
  @override
  Future<void> updateReminder(Reminder reminder) async =>
      throw UnsupportedError('Reminders are not part of the capture workflow');
}
