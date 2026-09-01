import 'package:cutting_log/src/domain/journal_overview.dart';

/// Empty local adapter used until the versioned database lands in issue #2.
final class InMemoryJournalRepository implements JournalRepository {
  const InMemoryJournalRepository();

  @override
  JournalOverview loadOverview() =>
      const JournalOverview(parentPlantCount: 0, activeCuttingCount: 0);
}
