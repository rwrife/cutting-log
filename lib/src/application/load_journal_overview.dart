import 'package:cutting_log/src/domain/journal_overview.dart';

/// Application use case that keeps views independent of storage details.
final class LoadJournalOverview {
  const LoadJournalOverview(this._repository);

  final JournalRepository _repository;

  JournalOverview call() => _repository.loadOverview();
}
