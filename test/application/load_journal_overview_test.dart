import 'package:cutting_log/src/application/load_journal_overview.dart';
import 'package:cutting_log/src/data/in_memory_journal_repository.dart';
import 'package:cutting_log/src/domain/startup_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('bootstrap application', () {
    test('loads an empty local journal through the repository boundary', () {
      const useCase = LoadJournalOverview(InMemoryJournalRepository());

      final overview = useCase();

      expect(overview.parentPlantCount, 0);
      expect(overview.activeCuttingCount, 0);
    });

    test('starts offline without account or optional permissions', () {
      const policy = StartupPolicy();

      expect(policy.requiresAccount, isFalse);
      expect(policy.requiresNetwork, isFalse);
      expect(policy.requestsOptionalPermissions, isFalse);
      expect(policy.storesDataLocally, isTrue);
    });
  });
}
