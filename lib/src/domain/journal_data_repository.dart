import 'package:cutting_log/src/domain/journal_entities.dart';

abstract base class JournalRepositoryException implements Exception {
  const JournalRepositoryException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class JournalConflictException extends JournalRepositoryException {
  const JournalConflictException(super.message);
}

final class JournalNotFoundException extends JournalRepositoryException {
  const JournalNotFoundException(super.message);
}

final class JournalTransitionException extends JournalRepositoryException {
  const JournalTransitionException(super.message);
}

/// Transaction-safe local persistence boundary for the journal domain.
abstract interface class JournalDataRepository {
  Future<void> addMediaAsset(MediaAsset asset);

  Future<void> appendEvent(CuttingEvent event);

  Future<void> archiveCutting(EntityId id, DateTime archivedAtUtc);

  Future<void> archiveParentPlant(EntityId id, DateTime archivedAtUtc);

  Future<void> createCutting(Cutting cutting);

  Future<void> createCuttingWithInitialEvent(
    Cutting cutting,
    CuttingEvent initialEvent,
  );

  Future<void> createParentPlant(ParentPlant parent);

  Future<void> createReminder(Reminder reminder);

  Future<Cutting?> getCutting(EntityId id);

  Future<List<CuttingEvent>> getCuttingEvents(EntityId cuttingId);

  Future<List<MediaAsset>> getMediaAssets(EntityId eventId);

  Future<ParentPlant?> getParentPlant(EntityId id);

  Future<List<Reminder>> getReminders(EntityId cuttingId);

  Future<void> updateCutting(Cutting cutting);

  Future<void> updateParentPlant(ParentPlant parent);

  Future<void> updateReminder(Reminder reminder);
}
