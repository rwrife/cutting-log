/// Counts shown by the journal shell before persistence is introduced.
final class JournalOverview {
  const JournalOverview({
    required this.parentPlantCount,
    required this.activeCuttingCount,
  });

  final int parentPlantCount;
  final int activeCuttingCount;
}

/// Domain-facing storage contract. Concrete persistence stays outside domain.
abstract interface class JournalRepository {
  JournalOverview loadOverview();
}
